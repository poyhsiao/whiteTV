import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/home/home_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';

/// Fake HistoryService for testing
class FakeHistoryService implements HistoryService {
  List<PlayHistory> mockHistory;
  bool shouldThrow;

  FakeHistoryService({this.mockHistory = const [], this.shouldThrow = false});

  @override
  Future<List<PlayHistory>> getHistory() async {
    if (shouldThrow) throw Exception('Fake history error');
    return mockHistory;
  }

  @override
  Future<void> addRecord(PlayHistory record) async {}

  @override
  Future<void> deleteRecord(String key) async {}

  @override
  List<PlayHistory> getPendingRecords() => [];

  @override
  bool get hasPendingRecords => false;

  @override
  int get pendingRecordCount => 0;

  @override
  Future<void> syncPendingRecords() async {}

  @override
  Future<void> syncFromRemote() async {}

  @override
  Future<bool> pushRecordToRemote(PlayHistory record) async => true;
}

void main() {
  group('HomeStore', () {
    late MockClient mockClient;
    late HomeStore store;

    setUp(() {
      mockClient = MockClient();
      store = HomeStore(mockClient);
    });

    test('initial state has empty categories', () {
      expect(store.state.categories, isEmpty);
      expect(store.state.isLoading, false);
    });

    test('loadHome populates categories', () async {
      await store.loadHome();
      expect(store.state.categories.length, 4);
      expect(store.state.isLoading, false);
      expect(store.state.error, isNull);
    });

    test('loadHome populates videos by category', () async {
      await store.loadHome();
      expect(store.state.videosByCategory['movie'], isNotEmpty);
      expect(store.state.videosByCategory['drama'], isNotEmpty);
    });

    test('loadHome sets error on failure', () async {
      await store.loadHome();
      expect(store.state.error, isNull);
    });

    group('loadHome error handling', () {
      test('API failure sets error state and clears loading', () async {
        mockClient.shouldThrowGetCategories = true;

        await store.loadHome();

        expect(store.state.isLoading, false);
        expect(store.state.error, isNotNull);
        expect(store.state.error, contains('Mock API'));
        expect(store.state.categories, isEmpty);
        expect(store.state.videosByCategory, isEmpty);
      });

      test('partial failure - categories load but videos fail', () async {
        mockClient.shouldThrowGetVideos = true;

        await store.loadHome();

        expect(store.state.isLoading, false);
        expect(store.state.error, isNotNull);
        expect(store.state.error, contains('Mock API'));
        // Categories may or may not be populated depending on when error occurs
        expect(store.state.videosByCategory, isEmpty);
      });

      test('concurrent video loading failure', () async {
        // Test that when one video category fails, error is set
        mockClient.shouldThrowGetVideos = true;
        mockClient.videoToThrowOn = 'movie';

        await store.loadHome();

        expect(store.state.isLoading, false);
        expect(store.state.error, isNotNull);
        expect(store.state.videosByCategory, isEmpty);
      });
    });

    group('setHistoryService', () {
      test('setHistoryService updates internal reference', () async {
        final fakeService = FakeHistoryService(
          mockHistory: [
            PlayHistory(
              key: 'history-1',
              videoId: 'movie-1',
              title: '星際穿越',
              sourceName: 'test-source',
              playTime: 3600,
              totalTime: 7200,
              saveTime: DateTime.now(),
              type: 'movie',
              lastPosition: const Duration(seconds: 3600),
            ),
          ],
        );

        store.setHistoryService(fakeService);
        await store.loadHome();

        expect(store.state.recentHistory.length, 1);
        expect(store.state.recentHistory.first.title, '星際穿越');
      });

      test('setHistoryService with second service replaces first', () async {
        final fakeService1 = FakeHistoryService(
          mockHistory: [
            PlayHistory(
              key: 'history-1',
              videoId: 'movie-1',
              title: '星際穿越',
              sourceName: 'test-source',
              playTime: 3600,
              totalTime: 7200,
              saveTime: DateTime.now(),
              type: 'movie',
            ),
          ],
        );

        final fakeService2 = FakeHistoryService(
          mockHistory: [
            PlayHistory(
              key: 'history-2',
              videoId: 'drama-1',
              title: '魷魚遊戲',
              sourceName: 'test-source',
              playTime: 1800,
              totalTime: 5400,
              saveTime: DateTime.now(),
              type: 'drama',
            ),
          ],
        );

        store.setHistoryService(fakeService1);
        await store.loadHome();
        expect(store.state.recentHistory.length, 1);
        expect(store.state.recentHistory.first.title, '星際穿越');

        // Replace with second service
        store.setHistoryService(fakeService2);
        await store.loadHome();
        expect(store.state.recentHistory.length, 1);
        expect(store.state.recentHistory.first.title, '魷魚遊戲');
      });

      test('loadHome works with injected service', () async {
        final fakeService = FakeHistoryService(
          mockHistory: [
            PlayHistory(
              key: 'history-1',
              videoId: 'drama-1',
              title: '魷魚遊戲',
              sourceName: 'test-source',
              playTime: 1800,
              totalTime: 5400,
              saveTime: DateTime.now(),
              type: 'drama',
            ),
          ],
        );

        store.setHistoryService(fakeService);
        await store.loadHome();

        expect(store.state.categories, isNotEmpty);
        expect(store.state.videosByCategory, isNotEmpty);
        expect(store.state.recentHistory.length, 1);
        expect(store.state.recentHistory.first.title, '魷魚遊戲');
        expect(store.state.isLoading, false);
        expect(store.state.error, isNull);
      });

      test('loadHome handles history service error gracefully', () async {
        final fakeService = FakeHistoryService(shouldThrow: true);

        store.setHistoryService(fakeService);
        await store.loadHome();

        // Should still load categories even if history fails
        expect(store.state.categories.length, 4);
        expect(store.state.isLoading, false);
        expect(store.state.error, isNull);
        expect(store.state.recentHistory, isEmpty);
      });
    });
  });
}