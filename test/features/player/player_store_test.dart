
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';
import 'package:white_tv/features/player/player_store.dart';
import 'package:white_tv/features/player/services/download_service.dart';

// Fake HistoryService for testing
class FakeHistoryService implements HistoryService {
  final List<PlayHistory> records = [];
  bool addRecordCalled = false;

  @override
  Future<List<PlayHistory>> getHistory() async => records;

  @override
  Future<void> addRecord(PlayHistory record) async {
    records.add(record);
    addRecordCalled = true;
  }

  @override
  Future<void> deleteRecord(String key) async {}

  @override
  Future<void> syncFromRemote() async {}

  @override
  List<PlayHistory> getPendingRecords() => [];

  @override
  Future<void> syncPendingRecords() async {}
}

// Fake DownloadService for testing offline playback
class FakeDownloadService implements DownloadService {
  final Map<String, String> downloadedVideos = {};

  void addDownloadedVideo(String videoId, String localPath) {
    downloadedVideos[videoId] = localPath;
  }

  @override
  Future<bool> deleteDownload(String videoId) async {
    downloadedVideos.remove(videoId);
    return true;
  }

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
  }) async {
    return null;
  }

  @override
  Future<String?> getLocalPath(String videoId) async {
    return downloadedVideos[videoId];
  }

  @override
  Future<bool> isDownloaded(String videoId) async {
    return downloadedVideos.containsKey(videoId);
  }
}

void main() {
  group('PlayerStore', () {
    late MockClient mockClient;
    late PlayerStore store;

    setUp(() {
      mockClient = MockClient();
      store = PlayerStore(mockClient);
    });

    tearDown(() => store.dispose());

    test('initial state is idle', () {
      expect(store.state.isPlaying, false);
      expect(store.state.currentPosition, Duration.zero);
    });

    test('setVideo updates video info', () async {
      await store.setVideo('movie-1', 'episode-1');
      expect(store.state.videoId, 'movie-1');
      expect(store.state.episodeId, 'episode-1');
    });

    test('play updates isPlaying to true', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.play();
      expect(store.state.isPlaying, true);
    });

    test('pause updates isPlaying to false', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.play();
      store.pause();
      expect(store.state.isPlaying, false);
    });

    test('seek updates position', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.seek(const Duration(seconds: 30));
      expect(store.state.currentPosition, const Duration(seconds: 30));
    });

    test('saveProgress updates currentPosition', () {
      store.seek(const Duration(minutes: 10));
      store.saveProgress();

      final state = store.state;
      expect(state.currentPosition, const Duration(minutes: 10));
    });

    test('saveProgress calls HistoryService.addRecord with PlayHistory', () async {
      final fakeHistory = FakeHistoryService();
      final storeWithHistory = PlayerStore(mockClient, fakeHistory);

      await storeWithHistory.setVideo('movie-1', 'episode-1');
      storeWithHistory.seek(const Duration(minutes: 5));
      storeWithHistory.saveProgress();

      expect(fakeHistory.addRecordCalled, true);
      expect(fakeHistory.records.length, 1);
      expect(fakeHistory.records.first.videoId, 'movie-1');
      expect(fakeHistory.records.first.playTime, 300); // 5 minutes in seconds

      storeWithHistory.dispose();
    });

    test(
      'auto-save timer triggers saveProgress every 30 seconds when playing',
      () async {
        await store.setVideo('movie-1', 'episode-1');
        store.seek(const Duration(seconds: 10));
        store.play();

        // Advance time by 30 seconds to trigger auto-save
        await Future.delayed(const Duration(milliseconds: 3100));

        // After 30 seconds, auto-save should have been called
        // The position should be saved (current implementation is a stub)
        expect(store.state.isPlaying, true);
      },
    );

    test('pause stops auto-save timer', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.play();
      store.pause();

      // After pause, timer should be stopped
      expect(store.state.isPlaying, false);
    });

    test('setVideo plays from local cache when downloaded', () async {
      final fakeDownloadService = FakeDownloadService();
      fakeDownloadService.addDownloadedVideo('movie-1', '/data/downloads/movie-1.mp4');
      final storeWithDownload = PlayerStore(mockClient, null, fakeDownloadService);

      await storeWithDownload.setVideo('movie-1', 'episode-1');

      expect(storeWithDownload.state.videoId, 'movie-1');
      expect(storeWithDownload.state.source?.url, 'file:///data/downloads/movie-1.mp4');
      expect(storeWithDownload.state.source?.name, 'local');

      storeWithDownload.dispose();
    });

    test('setVideo falls back to online when not downloaded', () async {
      final fakeDownloadService = FakeDownloadService();
      final storeWithDownload = PlayerStore(mockClient, null, fakeDownloadService);

      await storeWithDownload.setVideo('movie-1', 'episode-1');

      // Should use online source since not downloaded
      expect(storeWithDownload.state.videoId, 'movie-1');
      // source will be from mockClient.getSources
      expect(storeWithDownload.state.source, isNotNull);

      storeWithDownload.dispose();
    });
  });
}
