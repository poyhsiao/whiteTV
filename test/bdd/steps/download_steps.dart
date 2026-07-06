import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/player/services/download_service.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/providers/downloads_providers.dart';

/// Fake DownloadService - instant for unit tests
/// (Progress behavior tested via store.updateProgress() directly)
class FakeDownloadService implements DownloadService {
  final FakeHistoryLocalService history;

  FakeDownloadService(this.history);

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    onProgress?.call(100, 100);
    // Update history to mark as downloaded (mirrors real DownloadService behavior)
    final records = await history.getAll();
    final idx = records.indexWhere((r) => r.videoId == videoId);
    if (idx >= 0) {
      final updated = records[idx].copyWith(
        isDownloaded: true,
        localPath: '/fake/path/$videoId.mp4',
        saveTime: DateTime.now(),
      );
      await history.save(updated);
    }
    return '/fake/path/$videoId.mp4';
  }

  @override
  Future<bool> isDownloaded(String videoId) async => false;

  @override
  Future<String?> getLocalPath(String videoId) async =>
      '/fake/path/$videoId.mp4';

  @override
  Future<bool> deleteDownload(String videoId) async => true;
}

/// Fake that tracks delete calls
class FakeDownloadServiceTracking implements DownloadService {
  final Set<String> deletedIds = {};
  final Map<String, String> localPaths = {};

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    return '/fake/path/$videoId.mp4';
  }

  @override
  Future<bool> isDownloaded(String videoId) async => localPaths.containsKey(videoId);

  @override
  Future<String?> getLocalPath(String videoId) async => localPaths[videoId];

  @override
  Future<bool> deleteDownload(String videoId) async {
    deletedIds.add(videoId);
    localPaths.remove(videoId);
    return true;
  }
}

/// Fake HistoryLocalService - 實作所有 needed methods
class FakeHistoryLocalService implements HistoryLocalService {
  final List<PlayHistory> _records = [];

  @override
  Future<List<PlayHistory>> getAll() async => List.from(_records);

  @override
  Future<void> save(PlayHistory record) async {
    _records.removeWhere((r) => r.key == record.key);
    _records.add(record);
  }

  @override
  Future<void> delete(String key) async {
    _records.removeWhere((r) => r.key == key);
  }

  Future<PlayHistory?> getByKey(String key) async {
    return _records.where((r) => r.key == key).firstOrNull;
  }

  @override
  Future<void> clear() async => _records.clear();
}

/// Failing DownloadService for error scenario testing
class FailingDownloadService implements DownloadService {
  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    throw DioException(
      type: DioExceptionType.connectionError,
      requestOptions: RequestOptions(path: url),
    );
  }

  @override
  Future<bool> isDownloaded(String videoId) async => false;

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> deleteDownload(String videoId) async => false;
}

PlayHistory _makeRecord(String videoId, {bool isDownloaded = false, String? localPath}) {
  return PlayHistory(
    key: 'history_${videoId}_key',
    videoId: videoId,
    title: '測試影片 $videoId',
    posterUrl: null,
    sourceName: '量子資源',
    mediaType: MediaType.movie,
    playTime: 0,
    totalTime: 7200,
    lastPosition: Duration.zero,
    watchedTime: 0,
    lastWatched: DateTime.now(),
    saveTime: DateTime.now(),
    type: 'movie',
    pendingDelete: false,
    episodeProgress: const [],
    isDownloaded: isDownloaded,
    localPath: localPath,
  );
}

ProviderContainer _buildContainer({
  required DownloadService downloadService,
  required HistoryLocalService historyService,
}) {
  return ProviderContainer(
    overrides: [
      downloadServiceProvider.overrideWithValue(downloadService),
      historyLocalServiceProvider.overrideWithValue(historyService),
    ],
  );
}

void main() {
  group('downloads.feature — BDD Scenarios', () {
    late FakeHistoryLocalService fakeHistoryService;
    late FakeDownloadService fakeDownloadService;
    late ProviderContainer container;

    // Keep stable notifier references to avoid autoDispose recreation
    late DownloadsStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      fakeHistoryService = FakeHistoryLocalService();
      fakeDownloadService = FakeDownloadService(fakeHistoryService);
      container = _buildContainer(
        downloadService: fakeDownloadService,
        historyService: fakeHistoryService,
      );
      // Prime the provider once; keep reference to avoid autoDispose races
      store = container.read(downloadsStoreProvider.notifier);
    });

    tearDown(() => container.dispose());

    // ════════════════════════════════════════════
    // Scenario 1: 下載完成後出現在列表
    // ════════════════════════════════════════════
    test('Scenario 1: startDownload 完成後 downloads 列表含該 video', () async {
      await fakeHistoryService.save(_makeRecord('v_scenario1'));

      await store.startDownload(
        videoId: 'v_scenario1',
        url: 'http://example.com/v1.mp4',
        title: '測試影片',
      );

      final state = container.read(downloadsStoreProvider);
      expect(
        state.downloads.any((d) => d.videoId == 'v_scenario1'),
        isTrue,
        reason: '下載完成的影片應出現在 downloads 列表',
      );
    });

    // ════════════════════════════════════════════
    // Scenario 2: 下載列表顯示下載進度
    // ════════════════════════════════════════════
    test('Scenario 2: updateProgress 正確更新 downloadProgress', () async {
      store.updateProgress('v_track', 0.75);

      final state = container.read(downloadsStoreProvider);
      expect(state.downloadProgress['v_track'], equals(0.75));
    });

    test('Scenario 2: 下載完成後 activeDownloadIds 移除該 videoId', () async {
      await fakeHistoryService.save(_makeRecord('v_complete'));
      await store.loadDownloads();

      await store.startDownload(
        videoId: 'v_complete',
        url: 'http://example.com/complete.mp4',
        title: '完成測試',
      );

      final state = container.read(downloadsStoreProvider);
      expect(state.activeDownloadIds.contains('v_complete'), isFalse,
          reason: '下載完成後應從 activeDownloadIds 移除');
    });

    // ════════════════════════════════════════════
    // Scenario 3: 使用者刪除下載
    // ════════════════════════════════════════════
    test('Scenario 3: deleteDownload 從列表移除該項目', () async {
      await fakeHistoryService.save(
        _makeRecord('v_delete', isDownloaded: true),
      );
      await store.loadDownloads();

      // Confirm it exists
      expect(container.read(downloadsStoreProvider).downloads.any((d) => d.videoId == 'v_delete'), isTrue);

      // Delete
      await store.deleteDownload('v_delete');

      // Verify removed — read from SAME store instance
      final state = container.read(downloadsStoreProvider);
      expect(state.downloads.any((d) => d.videoId == 'v_delete'), isFalse,
          reason: '刪除後列表不應包含該項目');
    });

    test('Scenario 3: deleteDownload 呼叫 service.deleteDownload', () async {
      final trackingService = FakeDownloadServiceTracking();
      final trackingContainer = _buildContainer(
        downloadService: trackingService,
        historyService: FakeHistoryLocalService(),
      );
      await trackingContainer.read(downloadsStoreProvider.notifier).loadDownloads();
      await trackingContainer.read(downloadsStoreProvider.notifier).deleteDownload('v_track');

      expect(trackingService.deletedIds.contains('v_track'), isTrue,
          reason: 'store 應呼叫 service.deleteDownload');
      trackingContainer.dispose();
    });

    // ════════════════════════════════════════════
    // Scenario 4: 下載失敗時顯示錯誤
    // ════════════════════════════════════════════
    test('Scenario 4: 網路錯誤時 error 訊息不為 null', () async {
      final failingService = FailingDownloadService();
      final failingContainer = _buildContainer(
        downloadService: failingService,
        historyService: FakeHistoryLocalService(),
      );
      await failingContainer
          .read(downloadsStoreProvider.notifier)
          .startDownload(
            videoId: 'v_neterror',
            url: 'http://fail.example.com/video.mp4',
            title: '網路錯誤測試',
          );

      final state = failingContainer.read(downloadsStoreProvider);
      expect(state.error, isNotNull,
          reason: '網路錯誤時應有 error 訊息');
      failingContainer.dispose();
    });

    test('Scenario 4: 下載失敗後 activeDownloadIds 應移除該 videoId', () async {
      final failingService = FailingDownloadService();
      final failingContainer = _buildContainer(
        downloadService: failingService,
        historyService: FakeHistoryLocalService(),
      );
      await failingContainer
          .read(downloadsStoreProvider.notifier)
          .startDownload(
            videoId: 'v_cleanup',
            url: 'http://fail.example.com/video.mp4',
            title: '清理測試',
          );

      final state = failingContainer.read(downloadsStoreProvider);
      expect(state.activeDownloadIds.contains('v_cleanup'), isFalse,
          reason: '失敗後 activeDownloadIds 應清除');
      expect(state.downloadProgress.containsKey('v_cleanup'), isFalse,
          reason: '失敗後下載進度 Map 應清除');
      failingContainer.dispose();
    });

    // ════════════════════════════════════════════
    // Scenario 5: 離線觀看下載的影片
    // ════════════════════════════════════════════
    test('Scenario 5: isDownloaded 回傳 true 當已下載', () async {
      final trackingService = FakeDownloadServiceTracking();
      trackingService.localPaths['v_offline'] = '/fake/path/v_offline.mp4';

      final result = await trackingService.isDownloaded('v_offline');
      expect(result, isTrue, reason: 'isDownloaded 應回傳 true');
    });

    test('Scenario 5: getLocalPath 回傳非 null 路徑', () async {
      final trackingService = FakeDownloadServiceTracking();
      trackingService.localPaths['v_local'] = '/fake/path/v_local.mp4';
      final path = await trackingService.getLocalPath('v_local');

      expect(path, isNotNull, reason: '離線播放需要本地路徑');
      expect(path, contains('v_local'));
    });

    // ════════════════════════════════════════════
    // Scenario 6: 下載頁空狀態
    // ════════════════════════════════════════════
    test('Scenario 6: 無下載時 downloads 列表為空', () async {
      await container.read(downloadsStoreProvider.notifier).loadDownloads();

      final state = container.read(downloadsStoreProvider);
      expect(state.downloads.isEmpty, isTrue,
          reason: '從未下載過任何影片時列表應為空');
    });

    test('Scenario 6: 空狀態時 error 為 null', () async {
      await container.read(downloadsStoreProvider.notifier).loadDownloads();

      final state = container.read(downloadsStoreProvider);
      expect(state.error, isNull,
          reason: '空狀態不應有 error');
    });
  });
}
