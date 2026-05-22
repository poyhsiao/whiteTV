import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/history/services/history_remote_service.dart';
import 'package:white_tv/features/history/services/history_service.dart';

class MockHistoryLocalService extends Mock implements HistoryLocalService {}

class MockHistoryRemoteService extends Mock implements HistoryRemoteService {}

class FakePlayHistory extends Fake implements PlayHistory {}

void main() {
  late HistoryService historyService;
  late MockHistoryLocalService mockLocalService;
  late MockHistoryRemoteService mockRemoteService;

  setUpAll(() {
    registerFallbackValue(FakePlayHistory());
  });

  setUp(() {
    mockLocalService = MockHistoryLocalService();
    mockRemoteService = MockHistoryRemoteService();
    historyService = HistoryService(mockLocalService, mockRemoteService);
  });

  group('HistoryService', () {
    final testRecord = PlayHistory(
      key: 'test_key',
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

    group('getHistory', () {
      test('returns local records', () async {
        // Arrange
        final localRecords = [testRecord];
        when(
          () => mockLocalService.getAll(),
        ).thenAnswer((_) async => localRecords);

        // Act
        final result = await historyService.getHistory();

        // Assert
        expect(result, equals(localRecords));
        verify(() => mockLocalService.getAll()).called(1);
        verifyNever(() => mockRemoteService.fetchFromRemote());
      });
    });

    group('addRecord', () {
      test('saves to local storage and triggers remote sync', () async {
        // Arrange
        when(() => mockLocalService.save(any())).thenAnswer((_) async {});
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenAnswer((_) async => []);

        // Act
        await historyService.addRecord(testRecord);

        // Assert
        verify(() => mockLocalService.save(testRecord)).called(1);
      });
    });

    group('offline queue', () {
      test('adds record to offline queue when remote sync fails', () async {
        // Arrange
        when(() => mockLocalService.save(any())).thenAnswer((_) async {});
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenThrow(Exception('Network error'));

        // Act
        await historyService.addRecord(testRecord);

        // Assert
        final pendingRecords = historyService.getPendingRecords();
        expect(pendingRecords, contains(testRecord));
        expect(pendingRecords.length, 1);
      });

      test('syncPendingRecords removes records from queue on success',
          () async {
        // Arrange
        when(() => mockLocalService.save(any())).thenAnswer((_) async {});
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenAnswer((_) async => []);

        // Add a record that fails remote sync (queue it)
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenThrow(Exception('Network error'));
        await historyService.addRecord(testRecord);

        // Now remote works
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenAnswer((_) async => []);

        // Act
        await historyService.syncPendingRecords();

        // Assert
        final pendingRecords = historyService.getPendingRecords();
        expect(pendingRecords, isEmpty);
      });

      test('getPendingRecords returns all queued records', () async {
        // Arrange
        when(() => mockLocalService.save(any())).thenAnswer((_) async {});
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenThrow(Exception('Network error'));

        final record2 = PlayHistory(
          key: 'test_key_2',
          videoId: 'video_456',
          title: 'Test Show 2',
          posterUrl: 'https://example.com/poster2.jpg',
          sourceName: 'TestSource',
          currentEpisode: 1,
          totalEpisodes: 12,
          playTime: 1800,
          totalTime: 3600,
          saveTime: DateTime(2024, 1, 1),
          type: 'continue_watch',
        );

        await historyService.addRecord(testRecord);
        await historyService.addRecord(record2);

        // Act
        final pendingRecords = historyService.getPendingRecords();

        // Assert
        expect(pendingRecords.length, 2);
        expect(pendingRecords, contains(testRecord));
        expect(pendingRecords, contains(record2));
      });
    });

    group('deleteRecord', () {
      test('removes from local storage', () async {
        // Arrange
        const testKey = 'test_key';
        when(() => mockLocalService.delete(testKey)).thenAnswer((_) async {});
        when(
          () => mockRemoteService.fetchFromRemote(),
        ).thenAnswer((_) async => []);

        // Act
        await historyService.deleteRecord(testKey);

        // Assert
        verify(() => mockLocalService.delete(testKey)).called(1);
      });
    });
  });
}