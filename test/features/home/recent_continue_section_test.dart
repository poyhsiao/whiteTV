import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/home/widgets/recent_continue_section.dart';
import 'package:white_tv/features/history/history_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';

void main() {
  group('RecentContinueSection', () {
    testWidgets('shows nothing when no continue records', (tester) async {
      // Create a mock HistoryService that returns empty records
      final mockService = MockHistoryServiceForTest();

      final container = ProviderContainer(
        overrides: [
          historyStoreProvider.overrideWith((ref) => HistoryStore(mockService)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: RecentContinueSection())),
        ),
      );
      expect(find.text('继续观看'), findsNothing);

      container.dispose();
    });
  });
}

// Simple mock HistoryService for testing
class MockHistoryServiceForTest implements HistoryService {
  @override
  Future<List<PlayHistory>> getHistory() async => [];

  @override
  Future<void> addRecord(PlayHistory record) async {}

  @override
  Future<void> deleteRecord(String key) async {}

  @override
  Future<void> syncFromRemote() async {}

  @override
  Future<void> syncPendingRecords() async {}

  @override
  List<PlayHistory> getPendingRecords() => [];

  @override
  bool get hasPendingRecords => false;

  @override
  int get pendingRecordCount => 0;

  @override
  Future<bool> pushRecordToRemote(PlayHistory record) async => true;
}
