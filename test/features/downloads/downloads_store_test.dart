import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class FakeDownloadService implements DownloadService {
  final List<String> deletedVideoIds = [];
  
  @override
  Future<bool> deleteDownload(String videoId) async {
    deletedVideoIds.add(videoId);
    return true;
  }

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async => null;

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> isDownloaded(String videoId) async => false;
}

class FakeHistoryLocalService implements HistoryLocalService {
  final List<PlayHistory> records;
  
  FakeHistoryLocalService(this.records);
  
  @override
  Future<List<PlayHistory>> getAll() async => records;
  
  @override
  Future<void> save(PlayHistory history) async {}
  
  @override
  Future<void> delete(String key) async {}
  
  @override
  Future<void> clear() async {}
}

void main() {
  final testDownloads = [
    PlayHistory(
      key: 'key1',
      videoId: 'video1',
      title: 'Test Video 1',
      sourceName: 'Source A',
      saveTime: DateTime.now(),
      type: 'movie',
      mediaType: MediaType.movie,
      isDownloaded: true,
      localPath: '/path/to/video1.mp4',
      playTime: 0,
      totalTime: 7200,
      lastPosition: Duration.zero,
      watchedTime: 0,
    ),
    PlayHistory(
      key: 'key2',
      videoId: 'video2',
      title: 'Test Video 2',
      sourceName: 'Source B',
      saveTime: DateTime.now(),
      type: 'series',
      mediaType: MediaType.series,
      isDownloaded: true,
      localPath: '/path/to/video2.mp4',
      playTime: 0,
      totalTime: 3600,
      lastPosition: Duration.zero,
      watchedTime: 0,
    ),
  ];

  group('DownloadsStore', () {
    test('initial state is empty', () {
      final store = DownloadsStore(
        FakeDownloadService(),
        FakeHistoryLocalService([]),
      );
      expect(store.state.downloads, isEmpty);
      expect(store.state.isLoading, false);
      expect(store.state.error, isNull);
    });

    test('loadDownloads filters only downloaded records', () async {
      final historyService = FakeHistoryLocalService(testDownloads);
      final store = DownloadsStore(
        FakeDownloadService(),
        historyService,
      );

      await store.loadDownloads();

      expect(store.state.downloads.length, 2);
      expect(store.state.isLoading, false);
    });

    test('deleteDownload removes video from list', () async {
      final downloadService = FakeDownloadService();
      final historyService = FakeHistoryLocalService(testDownloads);
      final store = DownloadsStore(
        downloadService,
        historyService,
      );

      await store.loadDownloads();
      expect(store.state.downloads.length, 2);

      // deleteDownload removes from store's local state directly
      await store.deleteDownload('video1');

      // Verify the video was removed from store's state (not from history)
      expect(store.state.downloads.length, 1);
      expect(store.state.downloads.first.videoId, 'video2');
      expect(downloadService.deletedVideoIds, contains('video1'));
    });

    test('loadDownloads handles error', () async {
      final store = DownloadsStore(
        FakeDownloadService(),
        _ThrowingHistoryService(),
      );

      await store.loadDownloads();

      expect(store.state.isLoading, false);
      expect(store.state.error, isNotNull);
    });
  });
}

class _ThrowingHistoryService implements HistoryLocalService {
  @override
  Future<List<PlayHistory>> getAll() async => throw Exception('Load failed');

  @override
  Future<void> save(PlayHistory history) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}
}
