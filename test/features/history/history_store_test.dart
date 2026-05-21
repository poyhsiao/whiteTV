import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/history_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';

// Mock HistoryService for testing
class MockHistoryService implements HistoryService {
  List<PlayHistory> _records = [];
  bool shouldThrowError = false;

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
    _records.removeWhere((r) => r.key == key);
  }

  @override
  Future<void> syncFromRemote() async {
    // Mock implementation
  }

  void setRecords(List<PlayHistory> records) {
    _records = List.from(records);
  }

  void setShouldThrowError(bool value) {
    shouldThrowError = value;
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
  });
}
