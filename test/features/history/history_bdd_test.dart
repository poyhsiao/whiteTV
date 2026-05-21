import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/history/services/history_remote_service.dart';
import 'package:white_tv/features/history/services/history_service.dart';

void main() {
  group('Play History BDD Integration Tests', () {
    late HistoryService historyService;
    late HistoryLocalService localService;
    late HistoryRemoteService remoteService;
    late MockClient mockClient;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Create real service instances for integration testing
      localService = await HistoryLocalService.create();
      mockClient = MockClient();
      remoteService = HistoryRemoteService(mockClient);
      historyService = HistoryService(localService, remoteService);
    });

    group('Scenario: Add and view play history', () {
      test('Given user has no history, When they add a record via HistoryService, Then the record appears in getHistory()', () async {
        // Given: user has no history
        final initialHistory = await historyService.getHistory();
        expect(initialHistory, isEmpty);

        // When: they add a record via HistoryService
        final record = PlayHistory(
          key: 'test_key_1',
          videoId: 'video_123',
          title: 'Test Show',
          posterUrl: 'https://example.com/poster.jpg',
          sourceName: 'TestSource',
          currentEpisode: 1,
          totalEpisodes: 12,
          playTime: 1800,
          totalTime: 3600,
          saveTime: DateTime(2024, 1, 1),
          type: 'continue_watch',
        );

        await historyService.addRecord(record);

        // Then: the record appears in getHistory()
        final history = await historyService.getHistory();
        expect(history.length, 1);
        expect(history.first.key, 'test_key_1');
        expect(history.first.title, 'Test Show');
        expect(history.first.progressPercent, 50.0);
      });
    });

    group('Scenario: View history grouped by time', () {
      test('Given history has records from today and yesterday, When viewing history, Then records are grouped correctly', () async {
        // Given: history has records from today and yesterday
        final todayRecord = PlayHistory(
          key: 'today_key',
          videoId: 'video_today',
          title: 'Today Show',
          sourceName: 'Source1',
          playTime: 1000,
          totalTime: 2000,
          saveTime: DateTime.now(),
          type: 'continue_watch',
        );

        final yesterdayRecord = PlayHistory(
          key: 'yesterday_key',
          videoId: 'video_yesterday',
          title: 'Yesterday Show',
          sourceName: 'Source2',
          playTime: 500,
          totalTime: 1500,
          saveTime: DateTime.now().subtract(const Duration(days: 1)),
          type: 'continue_watch',
        );

        await historyService.addRecord(todayRecord);
        await historyService.addRecord(yesterdayRecord);

        // When: viewing history
        final history = await historyService.getHistory();

        // Then: records are grouped correctly (sorted by saveTime descending)
        expect(history.length, 2);
        expect(history.first.key, 'today_key'); // Most recent first
        expect(history.last.key, 'yesterday_key');
      });
    });

    group('Scenario: Delete play history', () {
      test('Given history has a record, When user deletes it via deleteRecord, Then record is removed from history', () async {
        // Given: history has a record
        final record = PlayHistory(
          key: 'delete_key',
          videoId: 'video_delete',
          title: 'Delete Me',
          sourceName: 'DeleteSource',
          playTime: 500,
          totalTime: 1000,
          saveTime: DateTime(2024, 1, 1),
          type: 'continue_watch',
        );

        await historyService.addRecord(record);

        // Verify record exists
        var history = await historyService.getHistory();
        expect(history.length, 1);
        expect(history.first.key, 'delete_key');

        // When: user deletes it via deleteRecord
        await historyService.deleteRecord('delete_key');

        // Then: record is removed from history
        history = await historyService.getHistory();
        expect(history, isEmpty);
      });
    });

    group('Scenario: Continue watching from history', () {
      test('Given history has a record with 50% progress and episode info, When user retrieves the record, Then progressPercent is 50.0 and episode info is correct', () async {
        // Given: history has a record with 50% progress and episode info
        final record = PlayHistory(
          key: 'continue_key',
          videoId: 'video_continue',
          title: 'Continue Show',
          posterUrl: 'https://example.com/continue.jpg',
          sourceName: 'ContinueSource',
          currentEpisode: 3,
          totalEpisodes: 10,
          playTime: 1800, // 50% of 3600
          totalTime: 3600,
          saveTime: DateTime(2024, 1, 1),
          type: 'continue_watch',
        );

        await historyService.addRecord(record);

        // When: user retrieves the record
        final history = await historyService.getHistory();

        // Then: progressPercent is 50.0 and episode info is correct
        expect(history.length, 1);
        final retrievedRecord = history.first;
        expect(retrievedRecord.progressPercent, 50.0);
        expect(retrievedRecord.currentEpisode, 3);
        expect(retrievedRecord.totalEpisodes, 10);
        expect(retrievedRecord.title, 'Continue Show');
        expect(retrievedRecord.sourceName, 'ContinueSource');
      });
    });
  });
}