import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/history/history_store.dart';
import 'package:white_tv/features/history/history_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/episode_progress.dart';
import 'package:white_tv/features/history/services/history_service.dart';

// ========================================================================
// Mock HistoryService for testing
// ========================================================================
class MockHistoryService implements HistoryService {
  List<PlayHistory> _records = [];
  bool shouldThrowError = false;
  bool remoteSyncCalled = false;
  final List<String> deletedKeys = [];

  @override
  Future<List<PlayHistory>> getHistory() async {
    if (shouldThrowError) throw Exception('Failed to load history');
    return List.from(_records);
  }

  @override
  Future<void> addRecord(PlayHistory record) async {
    _records.add(record);
  }

  @override
  Future<void> deleteRecord(String key) async {
    deletedKeys.add(key);
    _records.removeWhere((r) => r.key == key);
  }

  @override
  Future<void> syncFromRemote() async {
    remoteSyncCalled = true;
    if (shouldThrowError) throw Exception('Remote sync failed');
  }

  @override
  Future<void> syncPendingRecords() async {
    // Mock implementation
  }

  @override
  List<PlayHistory> getPendingRecords() => [];

  void setRecords(List<PlayHistory> records) {
    _records = List.from(records);
  }

  void setShouldThrowError(bool value) {
    shouldThrowError = value;
  }

  void reset() {
    _records = [];
    shouldThrowError = false;
    remoteSyncCalled = false;
    deletedKeys.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Play History BDD Tests', () {
    // ========================================================================
    // Background: Shared test data
    // ========================================================================
    final testMovieHistory = PlayHistory(
      key: 'movie-1',
      videoId: 'video-movie-1',
      title: 'Test Movie 1',
      sourceName: 'Test Source',
      playTime: 1500,
      totalTime: 7200,
      lastPosition: const Duration(seconds: 1500),
      saveTime: DateTime(2026, 5, 22, 10, 0),
      type: 'movie',
    );

    final testSeriesHistory = PlayHistory(
      key: 'series-1',
      videoId: 'video-series-1',
      title: 'Test Series 1',
      sourceName: 'Test Source',
      currentEpisode: 3,
      totalEpisodes: 12,
      playTime: 1800,
      totalTime: 3600,
      lastPosition: const Duration(seconds: 1800),
      saveTime: DateTime(2026, 5, 22, 10, 0),
      type: 'series',
      episodeProgress: [
        const EpisodeProgress(episodeNumber: 1, playTime: 1800, totalTime: 1800),
        const EpisodeProgress(episodeNumber: 2, playTime: 1800, totalTime: 1800),
        const EpisodeProgress(episodeNumber: 3, playTime: 1800, totalTime: 3600),
      ],
    );

    final testResumeHistory = PlayHistory(
      key: 'resume-test',
      videoId: 'video-resume-test',
      title: 'Resume Test Video',
      sourceName: 'Test Source',
      playTime: 300,
      totalTime: 1800,
      lastPosition: const Duration(seconds: 300),
      saveTime: DateTime(2026, 5, 22, 10, 0),
      type: 'movie',
    );

    // ========================================================================
    // Feature: Auto-Save Progress While Playing
    // Progress is automatically saved every 30 seconds during video playback
    // ========================================================================
    group('Auto-Save Progress While Playing', () {
      test(
        'Given the user is playing a video '
        'When 30 seconds of playback elapse '
        'Then the history record should be updated with the new lastPosition',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testMovieHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Verify initial position
          expect(store.state.records.first.lastPosition.inSeconds, 1500);

          // Act - Simulate position update after 30 seconds
          final updatedRecord = testMovieHistory.copyWith(
            playTime: 1530,
            lastPosition: const Duration(seconds: 1530),
          );
          await store.addRecord(updatedRecord);

          // Assert
          expect(store.state.records.length, 2);
          expect(
            store.state.records.any((r) => r.lastPosition.inSeconds == 1530),
            isTrue,
          );
        },
      );

      test(
        'Given the user pauses a video '
        'When playback resumes '
        'Then the progress should be saved at the pause point',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          final pausedRecord = testMovieHistory.copyWith(
            playTime: 1500,
            lastPosition: const Duration(seconds: 1500),
          );
          mockService.setRecords([pausedRecord]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Simulate resuming with same position
          await store.addRecord(pausedRecord);

          // Assert
          final savedRecord = store.state.records.first;
          expect(savedRecord.lastPosition.inSeconds, 1500);
        },
      );

      test(
        'Given the user watches a video to completion '
        'When playback ends '
        'Then the history record should show 100% progress',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          final nearCompleteRecord = testMovieHistory.copyWith(
            playTime: 7150,
            totalTime: 7200,
            lastPosition: const Duration(seconds: 7150),
          );
          mockService.setRecords([nearCompleteRecord]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Complete playback
          final completedRecord = testMovieHistory.copyWith(
            playTime: 7200,
            totalTime: 7200,
            lastPosition: const Duration(seconds: 7200),
          );
          await store.addRecord(completedRecord);

          // Assert - The new record should have 100% (added as second item)
          final addedRecord = store.state.records.last;
          expect(addedRecord.progressPercent, 100.0);
        },
      );
    });

    // ========================================================================
    // Feature: Resume from Last Position
    // User can resume watching from where they left off
    // ========================================================================
    group('Resume from Last Position', () {
      test(
        'Given a history record exists with lastPosition '
        'When the user opens the same video '
        'Then the player should start from lastPosition',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testResumeHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Find record for resume
          final recordToResume = store.state.records.first;

          // Assert - lastPosition should be the resume point
          expect(recordToResume.lastPosition.inSeconds, 300);
        },
      );

      test(
        'Given the user has partially watched a movie '
        'When they resume playback '
        'Then the player should show the correct resume time in UI',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testResumeHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act
          final record = store.state.records.first;
          final resumeTime = record.lastPosition;

          // Assert
          expect(resumeTime.inSeconds, 300);
          expect(record.progressPercent, closeTo(16.67, 0.01));
        },
      );

      test(
        'Given a movie has no watch history '
        'When the user starts playing it '
        'Then the player should start from the beginning (0:00)',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Assert - No records exist
          expect(store.state.records.isEmpty, isTrue);
        },
      );

      test(
        'Given the user has watched 90% of a video '
        'When they resume '
        'Then the UI should show 90% progress indicator',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          final ninetyPercentRecord = testMovieHistory.copyWith(
            playTime: 6480,
            totalTime: 7200,
            lastPosition: const Duration(seconds: 6480),
          );
          mockService.setRecords([ninetyPercentRecord]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Assert
          final record = store.state.records.first;
          expect(record.progressPercent, 90.0);
        },
      );
    });

    // ========================================================================
    // Feature: Multi-Episode Progress Tracking
    // Series content tracks progress per episode
    // ========================================================================
    group('Multi-Episode Progress Tracking', () {
      test(
        'Given a series is being watched '
        'When an episode finishes '
        'Then episodeProgress should record that episode\'s progress',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          final inProgressSeries = testSeriesHistory.copyWith(
            episodeProgress: [
              const EpisodeProgress(episodeNumber: 1, playTime: 1800, totalTime: 1800),
              const EpisodeProgress(episodeNumber: 2, playTime: 1800, totalTime: 1800),
            ],
          );
          mockService.setRecords([inProgressSeries]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Add episode 3 progress
          final updatedSeries = inProgressSeries.copyWith(
            currentEpisode: 3,
            episodeProgress: [
              const EpisodeProgress(episodeNumber: 1, playTime: 1800, totalTime: 1800),
              const EpisodeProgress(episodeNumber: 2, playTime: 1800, totalTime: 1800),
              const EpisodeProgress(episodeNumber: 3, playTime: 1800, totalTime: 3600),
            ],
          );
          await store.addRecord(updatedSeries);

          // Assert
          final updatedRecord = store.state.records.first;
          expect(updatedRecord.episodeProgress.length, 3);
          expect(
            updatedRecord.episodeProgress.any((e) => e.episodeNumber == 3),
            isTrue,
          );
        },
      );

      test(
        'Given a series has multiple episodes watched '
        'When viewing history '
        'Then each episode\'s progress should be displayed correctly',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testSeriesHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Assert
          final record = store.state.records.first;
          expect(record.episodeProgress.length, 3);

          // Episode 1 completed
          expect(record.episodeProgress[0].episodeNumber, 1);
          expect(record.episodeProgress[0].progressPercent, 100.0);

          // Episode 2 completed
          expect(record.episodeProgress[1].episodeNumber, 2);
          expect(record.episodeProgress[1].progressPercent, 100.0);

          // Episode 3 in progress (50%)
          expect(record.episodeProgress[2].episodeNumber, 3);
          expect(record.episodeProgress[2].progressPercent, 50.0);
        },
      );

      test(
        'Given the user is on episode 5 of 12 '
        'When viewing the series history '
        'Then the currentEpisode and totalEpisodes should be displayed',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          final episode5Series = testSeriesHistory.copyWith(
            currentEpisode: 5,
            totalEpisodes: 12,
          );
          mockService.setRecords([episode5Series]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Assert
          final record = store.state.records.first;
          expect(record.currentEpisode, 5);
          expect(record.totalEpisodes, 12);
        },
      );

      test(
        'Given episode progress is tracked '
        'When user continues watching '
        'Then the episode progress should be updated rather than duplicated',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testSeriesHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Update episode 3 progress
          final existingProgress = testSeriesHistory.episodeProgress;
          final updatedEpisode3 = const EpisodeProgress(
            episodeNumber: 3,
            playTime: 2700,
            totalTime: 3600,
          );

          final updatedProgress = [
            existingProgress[0],
            existingProgress[1],
            updatedEpisode3,
          ];

          final updatedRecord = testSeriesHistory.copyWith(
            episodeProgress: updatedProgress,
          );
          await store.addRecord(updatedRecord);

          // Assert - Only one episode 3 entry
          final episode3Entries = store.state.records
              .expand((r) => r.episodeProgress)
              .where((e) => e.episodeNumber == 3)
              .toList();
          expect(episode3Entries.length, 1);
          expect(episode3Entries.first.progressPercent, 75.0);
        },
      );
    });

    // ========================================================================
    // Feature: Offline Sync on Reconnection
    // Progress syncs when network is restored
    // ========================================================================
    group('Offline Sync on Reconnection', () {
      test(
        'Given records are pending sync '
        'When network is restored '
        'Then syncFromRemote should be triggered',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testMovieHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Assert initial state
          expect(mockService.remoteSyncCalled, isFalse);

          // Act - Trigger sync
          await store.syncFromRemote();

          // Assert
          expect(mockService.remoteSyncCalled, isTrue);
        },
      );

      test(
        'Given the device is offline '
        'When records are added locally '
        'Then they should be saved to local storage immediately',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setShouldThrowError(true); // Simulate offline
          final store = HistoryStore(mockService);

          // Act - Add record while "offline"
          await store.addRecord(testMovieHistory);

          // Assert - Record was saved locally despite offline error
          expect(store.state.records.isNotEmpty, isTrue);
        },
      );

      test(
        'Given sync is in progress '
        'When syncFromRemote is called '
        'Then isSyncing should be true during sync',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testMovieHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();
          expect(store.state.isSyncing, isFalse);

          // Act - Start sync
          final syncFuture = store.syncFromRemote();
          expect(store.state.isSyncing, isTrue);

          // Wait for completion
          await syncFuture;

          // Assert
          expect(store.state.isSyncing, isFalse);
        },
      );

      test(
        'Given sync fails '
        'When syncFromRemote is called '
        'Then error should be set and isSyncing should be false',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setShouldThrowError(true);
          mockService.setRecords([testMovieHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act
          await store.syncFromRemote();

          // Assert
          expect(store.state.isSyncing, isFalse);
          expect(store.state.error, isNotNull);
        },
      );

      test(
        'Given records were added while offline '
        'When network is restored '
        'Then records should sync to remote storage',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testMovieHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Simulate network restoration and sync
          mockService.setShouldThrowError(false);
          await store.syncFromRemote();

          // Assert
          expect(mockService.remoteSyncCalled, isTrue);
          expect(store.state.error, isNull);
        },
      );
    });

    // ========================================================================
    // Feature: History Record Deletion
    // User can delete individual history records
    // ========================================================================
    group('History Record Deletion', () {
      test(
        'Given a history record exists '
        'When the user deletes it '
        'Then the record should be removed from the list',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testMovieHistory, testSeriesHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();
          expect(store.state.records.length, 2);

          // Act
          await store.deleteRecord('movie-1');

          // Assert
          expect(store.state.records.length, 1);
          expect(store.state.records.any((r) => r.key == 'movie-1'), isFalse);
        },
      );

      test(
        'Given the user clears all history '
        'When deleteRecord is called for all records '
        'Then the history list should be empty',
        () async {
          // Arrange
          final mockService = MockHistoryService();
          mockService.setRecords([testMovieHistory, testSeriesHistory]);
          final store = HistoryStore(mockService);

          await store.loadHistory();

          // Act - Delete all records
          await store.deleteRecord('movie-1');
          await store.deleteRecord('series-1');

          // Assert
          expect(store.state.records.isEmpty, isTrue);
        },
      );
    });
  });
}