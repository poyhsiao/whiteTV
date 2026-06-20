import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';

/// 播放進度儲存服務
/// 使用 HistoryService 持久化播放進度，本地 Map 做同步查詢

class PlaybackProgressService {
  final HistoryService _historyService;
  final Map<String, PlayHistory> _localCache = {};
  DateTime? _lastSaveTime;

  /// 節流間隔：每10秒最多儲存一次
  static const Duration throttleInterval = Duration(seconds: 10);

  PlaybackProgressService(this._historyService);

  /// 儲存播放進度（節流：每10秒最多一次）
  Future<void> saveProgress(
    String videoId,
    String sourceId,
    int episodeNumber,
    Duration position,
    Duration totalDuration,
  ) async {
    final now = DateTime.now();
    if (_lastSaveTime != null &&
        now.difference(_lastSaveTime!) < throttleInterval) {
      return;
    }
    _lastSaveTime = now;

    final key = '${videoId}_ep$episodeNumber';
    final record = PlayHistory(
      key: key,
      videoId: videoId,
      title: '',
      sourceName: sourceId,
      currentEpisode: episodeNumber,
      playTime: position.inSeconds,
      totalTime: totalDuration.inSeconds,
      lastPosition: position,
      lastWatched: now,
      saveTime: now,
      type: 'movie',
    );

    _localCache[key] = record;
    await _historyService.addRecord(record);
  }

  /// 載入上次播放進度
  PlayHistory? loadProgress(String videoId, int episodeNumber) {
    final key = '${videoId}_ep$episodeNumber';
    return _localCache[key];
  }

  /// 刪除進度（看完時）
  Future<void> deleteProgress(String videoId, int episodeNumber) async {
    final key = '${videoId}_ep$episodeNumber';
    _localCache.remove(key);
    await _historyService.deleteRecord(key);
  }

  /// 重置節流計時器（測試用）
  void resetThrottle() {
    _lastSaveTime = null;
  }
}
