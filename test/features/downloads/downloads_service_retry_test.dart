import 'dart:io';
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

/// Spies on download() calls and controls when errors propagate.
class RetryTrackingDownloadService implements DownloadService {
  RetryTrackingDownloadService({
    this.shouldFail = false,
    this.failOnAttempt = 1,
    this.maxRetriesOverride,
    DioException? failError,
  }) : _failError = failError ??
            DioException(
              type: DioExceptionType.connectionTimeout,
              requestOptions: RequestOptions(path: ''),
            );

  final bool shouldFail;
  final int failOnAttempt;
  final DioException _failError;
  final int? maxRetriesOverride;

  int callCount = 0;
  int? lastMaxRetries;

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    callCount++;
    lastMaxRetries = maxRetries;

    if (shouldFail && callCount >= failOnAttempt) {
      throw _failError;
    }
    return '/fake/$videoId.mp4';
  }

  @override
  Future<bool> isDownloaded(String videoId) async => false;

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> deleteDownload(String videoId) async => true;
}

/// Service that always throws FileSystemException (non-retryable, non-Dio).
class FileErrorDownloadService implements DownloadService {
  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    throw const FileSystemException('磁碟空間不足');
  }

  @override
  Future<bool> isDownloaded(String videoId) async => false;

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> deleteDownload(String videoId) async => true;
}

/// Records whether store exposed an error.
class TestDownloadsStore extends DownloadsStore {
  TestDownloadsStore(super.downloadService, super.historyService);

  bool errorObserved = false;
  String? observedError;

  // ponytail: TestDownloadsStore adds a setError hook for assertions;
  // DownloadsStore does not expose setError, so no @override here.
  void setError(String? error) {
    observedError = error;
    errorObserved = error != null;
  }
}

PlayHistory _makeRecord(String videoId) {
  return PlayHistory(
    key: 'key_$videoId',
    videoId: videoId,
    title: 'Test $videoId',
    posterUrl: null,
    sourceName: 'test',
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
    isDownloaded: false,
    localPath: null,
  );
}

void main() {
  group('DownloadsStore 重試機制', () {
    late ProviderContainer container;
    late HistoryLocalService historyService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      historyService = HistoryLocalService(prefs);
    });

    tearDown(() => container.dispose());

    test('downloadService.download 被調用時 maxRetries 為 3', () async {
      final uniqueId = 'v_spy_${DateTime.now().millisecondsSinceEpoch}';
      await historyService.save(_makeRecord(uniqueId));
      final spy = RetryTrackingDownloadService();

      container = ProviderContainer(
        overrides: [
          downloadServiceProvider.overrideWithValue(spy),
          historyLocalServiceProvider.overrideWithValue(historyService),
        ],
      );

      await container.read(downloadsStoreProvider.notifier).startDownload(
            videoId: uniqueId,
            url: 'https://e.com/v.mp4',
            title: 'Test',
          );

      expect(spy.callCount, greaterThan(0));
      expect(spy.lastMaxRetries, equals(3));
    });

    test('下載成功時 error 為 null', () async {
      final uniqueId = 'v_ok_${DateTime.now().millisecondsSinceEpoch}';
      await historyService.save(_makeRecord(uniqueId));
      final spy = RetryTrackingDownloadService();

      container = ProviderContainer(
        overrides: [
          downloadServiceProvider.overrideWithValue(spy),
          historyLocalServiceProvider.overrideWithValue(historyService),
        ],
      );

      await container.read(downloadsStoreProvider.notifier).startDownload(
            videoId: uniqueId,
            url: 'https://e.com/v.mp4',
            title: 'Test',
          );

      final state = container.read(downloadsStoreProvider);
      expect(state.error, isNull);
      expect(state.activeDownloadIds.contains(uniqueId), isFalse);
    });

    test('下載服務拋出網路錯誤後 error 不為 null', () async {
      final uniqueId = 'v_net_${DateTime.now().millisecondsSinceEpoch}';
      await historyService.save(_makeRecord(uniqueId));
      final spy = RetryTrackingDownloadService(
        shouldFail: true,
        failOnAttempt: 1,
      );

      container = ProviderContainer(
        overrides: [
          downloadServiceProvider.overrideWithValue(spy),
          historyLocalServiceProvider.overrideWithValue(historyService),
        ],
      );

      await container.read(downloadsStoreProvider.notifier).startDownload(
            videoId: uniqueId,
            url: 'https://e.com/v.mp4',
            title: 'Test',
          );

      // After await returns, all retries have exhausted → error should be set
      final state = container.read(downloadsStoreProvider);
      expect(state.error, isNotNull,
          reason: '網路錯誤後 store.state.error 應不為 null');
      expect(state.activeDownloadIds.contains(uniqueId), isFalse,
          reason: '失敗後 activeDownloadIds 應清除');
    });

    test('下載服務拋出非網路錯誤後 error 不為 null', () async {
      final uniqueId = 'v_fs_${DateTime.now().millisecondsSinceEpoch}';
      await historyService.save(_makeRecord(uniqueId));

      // FileSystemException is NOT caught by the service's retry loop
      // so the store's general Exception handler should catch it
      container = ProviderContainer(
        overrides: [
          downloadServiceProvider.overrideWithValue(FileErrorDownloadService()),
          historyLocalServiceProvider.overrideWithValue(historyService),
        ],
      );

      await container.read(downloadsStoreProvider.notifier).startDownload(
            videoId: uniqueId,
            url: 'https://e.com/v.mp4',
            title: 'Test',
          );

      final state = container.read(downloadsStoreProvider);
      expect(state.error, isNotNull,
          reason: '非網路錯誤後 store.state.error 應不為 null');
      expect(state.activeDownloadIds.contains(uniqueId), isFalse);
    });
  });
}
