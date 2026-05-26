import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/history_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';

// Mock HistoryService for testing
class MockHistoryService implements HistoryService {
  List<PlayHistory> _records = [];
  bool shouldThrowError = false;
  bool shouldThrowOnSync = false;
  bool shouldThrowOnDelete = false;

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
    if (shouldThrowOnDelete) throw Exception('Failed to delete record');
    _records.removeWhere((r) => r.key == key);
  }

  @override
  Future<void> syncFromRemote() async {
    // Mock implementation
  }

  @override
  List<PlayHistory> getPendingRecords() => List.from(_records);

  @override
  Future<void> syncPendingRecords() async {
    if (shouldThrowOnSync) throw Exception('Failed to sync pending records');
  }

  @override
  bool get hasPendingRecords => _records.isNotEmpty;

  @override
  int get pendingRecordCount => _records.length;

  @override
  Future<bool> pushRecordToRemote(PlayHistory record) async {
    // Mock implementation - always succeeds
    return true;
  }

  void setRecords(List<PlayHistory> records) {
    _records = List.from(records);
  }

  void setShouldThrowError(bool value) {
    shouldThrowError = value;
  }

  void setShouldThrowOnSync(bool value) {
    shouldThrowOnSync = value;
  }

  void setShouldThrowOnDelete(bool value) {
    shouldThrowOnDelete = value;
  }
}

void main() {
  group('HistoryStore', () {
    late MockHistoryService mockService;
    late ProviderContainer container;

    final testRecord = PlayHistory(
      key: 'test-key-1',
      videoId: 'video-1',
      title: 'Test Video',
      sourceName: 'Test Source',
      playTime: 100,
      totalTime: 1000,
      saveTime: DateTime(2024, 1, 1),
      type: 'movie',
    );

    final testRecord2 = PlayHistory(
      key: 'test-key-2',
      videoId: 'video-2',
      title: 'Test Video 2',
      sourceName: 'Test Source 2',
      playTime: 200,
      totalTime: 2000,
      saveTime: DateTime(2024, 1, 2),
      type: 'series',
    );

    setUp(() {
      mockService = MockHistoryService();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'initial state is empty (records=[], isLoading=false, error=null)',
      () {
        final store = HistoryStore(mockService);
        expect(store.state.records, isEmpty);
        expect(store.state.isLoading, isFalse);
        expect(store.state.error, isNull);
        expect(store.state.isSyncing, isFalse);
      },
    );

    test('loadHistory fetches records and updates state', () async {
      mockService.setRecords([testRecord, testRecord2]);
      final store = HistoryStore(mockService);

      await store.loadHistory();

      expect(store.state.records.length, equals(2));
      expect(store.state.records[0].key, equals('test-key-1'));
      expect(store.state.records[1].key, equals('test-key-2'));
      expect(store.state.isLoading, isFalse);
      expect(store.state.error, isNull);
    });

    test('loadHistory sets loading state during fetch', () async {
      mockService.setRecords([testRecord]);
      final store = HistoryStore(mockService);

      // Start loading
      final future = store.loadHistory();
      expect(store.state.isLoading, isTrue);

      // Wait for completion
      await future;
      expect(store.state.isLoading, isFalse);
    });

    test('loadHistory sets error on failure', () async {
      mockService.setShouldThrowError(true);
      final store = HistoryStore(mockService);

      await store.loadHistory();

      expect(store.state.records, isEmpty);
      expect(store.state.isLoading, isFalse);
      expect(store.state.error, isNotNull);
      expect(store.state.error, equals('Exception: Failed to load history'));
    });

    test('deleteRecord removes record from state', () async {
      mockService.setRecords([testRecord, testRecord2]);
      final store = HistoryStore(mockService);

      // Load history first
      await store.loadHistory();
      expect(store.state.records.length, equals(2));

      // Delete one record
      await store.deleteRecord('test-key-1');

      expect(store.state.records.length, equals(1));
      expect(store.state.records[0].key, equals('test-key-2'));
    });

    test('deleteRecord with non-existent key does not throw and state unchanged',
        () async {
      mockService.setRecords([testRecord]);
      final store = HistoryStore(mockService);

      await store.loadHistory();
      expect(store.state.records.length, equals(1));

      // Delete non-existent key should not throw
      await store.deleteRecord('non-existent-key');

      // State should remain unchanged
      expect(store.state.records.length, equals(1));
      expect(store.state.records[0].key, equals('test-key-1'));
    });

    test('deleteRecord error handling sets error state', () async {
      mockService.setRecords([testRecord]);
      mockService.setShouldThrowOnDelete(true);
      final store = HistoryStore(mockService);

      await store.loadHistory();
      expect(store.state.error, isNull);

      await store.deleteRecord('test-key-1');

      expect(store.state.error, isNotNull);
      expect(store.state.error, contains('Failed to delete record'));
    });

    test('syncPendingRecords success clears isSyncing', () async {
      mockService.setRecords([testRecord]);
      final store = HistoryStore(mockService);

      await store.loadHistory();

      // Start syncing
      final future = store.syncPendingRecords();
      expect(store.state.isSyncing, isTrue);

      // Wait for completion
      await future;
      expect(store.state.isSyncing, isFalse);
    });

    test('syncPendingRecords error sets error and clears isSyncing', () async {
      mockService.setShouldThrowOnSync(true);
      final store = HistoryStore(mockService);

      await store.syncPendingRecords();

      expect(store.state.error, isNotNull);
      expect(store.state.error, contains('Failed to sync pending records'));
      expect(store.state.isSyncing, isFalse);
    });

    // continueWatchRecords test records
    final recordWith10Percent = PlayHistory(
      key: 'key-10pct',
      videoId: 'video-10pct',
      title: '10 Percent',
      sourceName: 'Source',
      playTime: 100,
      totalTime: 1000, // 10% progress
      saveTime: DateTime(2024, 1, 1),
      lastWatched: DateTime(2024, 1, 3),
      type: 'movie',
    );

    final recordWith50Percent = PlayHistory(
      key: 'key-50pct',
      videoId: 'video-50pct',
      title: '50 Percent',
      sourceName: 'Source',
      playTime: 500,
      totalTime: 1000, // 50% progress
      saveTime: DateTime(2024, 1, 1),
      lastWatched: DateTime(2024, 1, 5),
      type: 'movie',
    );

    final recordWith100Percent = PlayHistory(
      key: 'key-100pct',
      videoId: 'video-100pct',
      title: '100 Percent',
      sourceName: 'Source',
      playTime: 1000,
      totalTime: 1000, // 100% progress (completed)
      saveTime: DateTime(2024, 1, 1),
      lastWatched: DateTime(2024, 1, 7),
      type: 'movie',
    );

    final recordWith3Percent = PlayHistory(
      key: 'key-3pct',
      videoId: 'video-3pct',
      title: '3 Percent',
      sourceName: 'Source',
      playTime: 30,
      totalTime: 1000, // 3% progress (below threshold)
      saveTime: DateTime(2024, 1, 1),
      lastWatched: DateTime(2024, 1, 9),
      type: 'movie',
    );

    test('continueWatchRecords filters correctly (5% < progress < 100%)',
        () async {
      mockService.setRecords([
        recordWith10Percent,
        recordWith50Percent,
        recordWith100Percent,
        recordWith3Percent,
      ]);
      final store = HistoryStore(mockService);

      await store.loadHistory();
      final continueWatching = store.continueWatchRecords;

      // Should include 10% and 50%, exclude 100% (completed) and 3% (below 5%)
      expect(continueWatching.length, equals(2));
      expect(continueWatching.map((r) => r.key), containsAll(['key-10pct', 'key-50pct']));
    });

    test('continueWatchRecords sorts by lastWatched descending', () async {
      mockService.setRecords([recordWith10Percent, recordWith50Percent]);
      final store = HistoryStore(mockService);

      await store.loadHistory();
      final continueWatching = store.continueWatchRecords;

      // 50% has lastWatched Jan 5, 10% has lastWatched Jan 3
      // Should be sorted: 50% first, then 10%
      expect(continueWatching[0].key, equals('key-50pct'));
      expect(continueWatching[1].key, equals('key-10pct'));
    });

    test('continueWatchRecords empty when no records match criteria',
        () async {
      mockService.setRecords([recordWith100Percent, recordWith3Percent]);
      final store = HistoryStore(mockService);

      await store.loadHistory();
      final continueWatching = store.continueWatchRecords;

      // All records are either 100% (completed) or 3% (below threshold)
      expect(continueWatching, isEmpty);
    });
  });
}
