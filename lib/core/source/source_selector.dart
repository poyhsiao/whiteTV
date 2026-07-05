import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_metrics.dart';

/// 來源選擇器
/// 負責來源測速、選擇邏輯、歷史追蹤

class SourceSelector {
  static const Duration cacheMaxAge = Duration(minutes: 30);
  static const int maxAutoSwitch = 2;

  final Map<String, SourceMetrics> _metrics = {};
  final Map<String, _CachedSource> _cache = {};
  List<String> _blockedSources = [];

  /// Sprint 8.2 — factory for `dart:io` HttpClient. Default uses real
  /// HttpClient(); tests override with a stub that returns canned responses.
  final HttpClient Function() _httpClientFactory;

  /// Sprint 8.3 — async reader for the persisted blocked-source list.
  /// Default reads `blocked_sources` from SharedPreferences; tests inject
  /// an in-memory function to avoid real storage I/O.
  final Future<List<String>> Function() _prefsReader;

  /// Sprint 8.3 — async writer for the persisted blocked-source list.
  /// Default writes to SharedPreferences; tests inject an in-memory function.
  final Future<void> Function(List<String>) _prefsWriter;

  SourceSelector({
    HttpClient Function()? httpClientFactory,
    Future<List<String>> Function()? prefsReader,
    Future<void> Function(List<String>)? prefsWriter,
  })  : _httpClientFactory = httpClientFactory ?? _defaultHttpClientFactory,
        _prefsReader = prefsReader ?? _defaultPrefsReader,
        _prefsWriter = prefsWriter ?? _defaultPrefsWriter;

  static HttpClient _defaultHttpClientFactory() => HttpClient();

  static Future<List<String>> _defaultPrefsReader() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('blocked_sources')?.toList() ?? const [];
  }

  static Future<void> _defaultPrefsWriter(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blocked_sources', ids);
  }

  /// 選擇最佳來源
  /// 1. 過濾屏蔽和不可用來源（每次從 SharedPreferences 刷新屏蔽名單以保持同步）
  /// 2. 檢查快取是否有效
  /// 3. 如果快取過期則重新測速
  /// 4. 返回最快來源
  Future<VideoSource> selectSource(List<VideoSource> sources, String videoId) async {
    if (sources.isEmpty) {
      throw ArgumentError('sources 不能為空');
    }

    // ponytail: 每次選擇前刷新屏蔽名單，保持與 SettingsStore 同步
    await _refreshBlockedSources();

    // 過濾屏蔽來源
    final availableSources = sources.where((s) {
      return !_blockedSources.contains(s.id) && s.isAvailable;
    }).toList();

    if (availableSources.isEmpty) {
      // 所有來源都被屏蔽或不可用時，返回原列表第一個（前提是它可用）
      final firstSource = sources.first;
      if (firstSource.isAvailable) return firstSource;
      // 第一個也不可用，返回原列表作為最後備用（呼叫端需處理）
      return firstSource;
    }

    // 檢查快取
    final cacheKey = videoId;
    final cached = _cache[cacheKey];

    if (cached != null && DateTime.now().difference(cached.timestamp) < cacheMaxAge) {
      // 快取有效，返回快取的最快來源
      final cachedSource = availableSources.firstWhere(
        (s) => s.id == cached.sourceId,
        orElse: () => availableSources.first,
      );
      return cachedSource;
    }

    // 快取過期或不存在，重新測速
    final testedSources = await speedTest(availableSources);

    // 更新快取
    if (testedSources.isNotEmpty) {
      _cache[cacheKey] = _CachedSource(
        sourceId: testedSources.first.id,
        timestamp: DateTime.now(),
      );
    }

    return testedSources.isNotEmpty ? testedSources.first : availableSources.first;
  }

  /// 並行測速所有來源
  /// 返回按延遲排序的來源列表（最快在前）
  Future<List<VideoSource>> speedTest(List<VideoSource> sources) async {
    final results = await Future.wait(
      sources.map((source) => testSingleSource(source)),
    );

    // 按延遲排序
    results.sort((a, b) => a.latency.compareTo(b.latency));

    return results;
  }

  /// 測試單個來源 URL 的延遲
  /// 使用 HEAD 請求測量響應時間
  Future<VideoSource> testSingleSource(VideoSource source) async {
    final stopwatch = Stopwatch()..start();
    final client = _httpClientFactory();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final request = await client.headUrl(Uri.parse(source.url));
      await request.close().timeout(const Duration(seconds: 5));

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      return VideoSource(
        id: source.id,
        name: source.name,
        url: source.url,
        latency: latency,
        isAvailable: true,
      );
    } catch (e) {
      stopwatch.stop();
      return VideoSource(
        id: source.id,
        name: source.name,
        url: source.url,
        latency: 9999,
        isAvailable: false,
      );
    } finally {
      client.close();
    }
  }

  /// 記錄播放結果
  void recordResult(String sourceId, {required bool isSuccess, int latency = 0}) {
    final metrics = _metrics.putIfAbsent(
      sourceId,
      () => SourceMetrics(sourceId: sourceId),
    );

    if (isSuccess) {
      metrics.recordSuccess(latency: latency > 0 ? latency : 100); // 預設 100ms
    } else {
      metrics.recordFailure();
    }
  }

  /// 獲取來源指標
  SourceMetrics? getMetrics(String sourceId) {
    return _metrics[sourceId];
  }

  /// 設置屏蔽來源列表
  Future<void> setBlockedSources(List<String> sources) async {
    _blockedSources = List.from(sources);
    await _prefsWriter(List<String>.from(_blockedSources));
  }

  /// 獲取屏蔽來源列表
  List<String> getBlockedSources() {
    return List.from(_blockedSources);
  }

  /// 加載屏蔽來源列表（從持久化存儲）
  Future<void> loadBlockedSources() async {
    await _refreshBlockedSources();
  }

  /// 刷新屏蔽來源列表（每次選擇時調用以保持同步）
  Future<void> _refreshBlockedSources() async {
    _blockedSources = await _prefsReader();
  }

  /// 清除快取
  void clearCache() {
    _cache.clear();
  }

  /// 獲取快取剩餘有效時間
  Duration? getCacheRemainingTime(String videoId) {
    final cached = _cache[videoId];
    if (cached == null) return null;

    final elapsed = DateTime.now().difference(cached.timestamp);
    final remaining = cacheMaxAge - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class _CachedSource {
  final String sourceId;
  final DateTime timestamp;

  _CachedSource({required this.sourceId, required this.timestamp});
}