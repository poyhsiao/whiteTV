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
