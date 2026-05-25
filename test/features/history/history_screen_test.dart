import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/history_screen.dart';
import 'package:white_tv/features/history/history_state.dart';
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

  @override
  List<PlayHistory> getPendingRecords() => List.from(_records);

  @override
  Future<void> syncPendingRecords() async {
    // Mock implementation - no-op for tests
  }

  @override
  bool get hasPendingRecords => _records.isNotEmpty;

  @override
  int get pendingRecordCount => _records.length;

  @override
  Future<bool> pushRecordToRemote(PlayHistory record) async => true;

  void setRecords(List<PlayHistory> records) {
    _records = List.from(records);
  }

  void setShouldThrowError(bool value) {
    shouldThrowError = value;
  }
}

void main() {
  group('HistoryScreen', () {
    late MockHistoryService mockService;

    final testRecord = PlayHistory(
      key: 'test-key-1',
      videoId: 'video-1',
      title: 'Test Video',
      sourceName: 'Test Source',
      playTime: 100,
      totalTime: 1000,
      saveTime: DateTime.now(),
      type: 'movie',
    );

    setUp(() {
      mockService = MockHistoryService();
    });

    Widget createTestWidget({HistoryState? initialState}) {
      if (initialState != null) {
        mockService.setRecords(initialState.records);
      }

      return ProviderScope(
        overrides: [
          historyStoreProvider.overrideWith((ref) => HistoryStore(mockService)),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      );
    }

    testWidgets('displays empty state when no records', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: const HistoryState(isLoading: false, records: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('還沒有觀看記錄'), findsOneWidget);
    });

    testWidgets('displays records when available', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: HistoryState(isLoading: false, records: [testRecord]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Video'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog on long press', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: HistoryState(isLoading: false, records: [testRecord]),
        ),
      );
      await tester.pumpAndSettle();

      // Find and long press the history tile
      final tile = find.text('Test Video');
      await tester.longPress(tile);
      await tester.pumpAndSettle();

      // Verify delete confirmation dialog appears
      expect(find.text('刪除觀看記錄'), findsOneWidget);
      expect(find.text('確定要刪除這筆記錄嗎？'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('刪除'), findsOneWidget);
    });
  });
}
