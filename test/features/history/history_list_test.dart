import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/widgets/history_list.dart';
import 'package:white_tv/features/history/widgets/history_tile.dart';

void main() {
  group('HistoryList', () {
    late List<PlayHistory> testRecords;
    late List<String> tappedKeys;
    late List<String> deletedKeys;

    setUp(() {
      tappedKeys = [];
      deletedKeys = [];
    });

    PlayHistory createHistory({
      required String key,
      required DateTime saveTime,
    }) {
      return PlayHistory(
        key: key,
        videoId: 'video_$key',
        title: 'Title $key',
        sourceName: 'Source $key',
        playTime: 100,
        totalTime: 200,
        saveTime: saveTime,
        type: 'movie',
      );
    }

    Widget buildWidget(List<PlayHistory> records) {
      return MaterialApp(
        home: Scaffold(
          body: HistoryList(
            records: records,
            onTap: (history) => tappedKeys.add(history.key),
            onDelete: (history) => deletedKeys.add(history.key),
          ),
        ),
      );
    }

    testWidgets('shows empty state when no records', (tester) async {
      await tester.pumpWidget(buildWidget([]));

      expect(find.text('還沒有觀看記錄'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('groups records by time period - 今天', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      testRecords = [
        createHistory(key: '1', saveTime: now),
        createHistory(key: '2', saveTime: today.add(const Duration(hours: 1))),
      ];

      await tester.pumpWidget(buildWidget(testRecords));

      expect(find.text('今天'), findsOneWidget);
      expect(find.text('昨天'), findsNothing);
      expect(find.text('更早'), findsNothing);
      expect(find.byType(HistoryTile), findsNWidgets(2));
    });

    testWidgets('groups records by time period - 昨天', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      testRecords = [
        createHistory(key: '1', saveTime: yesterday),
        createHistory(
          key: '2',
          saveTime: yesterday.add(const Duration(hours: 5)),
        ),
      ];

      await tester.pumpWidget(buildWidget(testRecords));

      expect(find.text('昨天'), findsOneWidget);
      expect(find.text('今天'), findsNothing);
      expect(find.text('更早'), findsNothing);
      expect(find.byType(HistoryTile), findsNWidgets(2));
    });

    testWidgets('groups records by time period - 更早', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      testRecords = [
        createHistory(key: '1', saveTime: twoDaysAgo),
        createHistory(
          key: '2',
          saveTime: twoDaysAgo.subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(buildWidget(testRecords));

      expect(find.text('更早'), findsOneWidget);
      expect(find.text('今天'), findsNothing);
      expect(find.text('昨天'), findsNothing);
      expect(find.byType(HistoryTile), findsNWidgets(2));
    });

    testWidgets('groups records correctly with mixed time periods', (
      tester,
    ) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      testRecords = [
        createHistory(key: 'today', saveTime: now),
        createHistory(key: 'yesterday', saveTime: yesterday),
        createHistory(key: 'older', saveTime: twoDaysAgo),
      ];

      await tester.pumpWidget(buildWidget(testRecords));

      expect(find.text('今天'), findsOneWidget);
      expect(find.text('昨天'), findsOneWidget);
      expect(find.text('更早'), findsOneWidget);
      expect(find.byType(HistoryTile), findsNWidgets(3));
    });

    testWidgets('calls onTap with correct record', (tester) async {
      final now = DateTime.now();

      testRecords = [createHistory(key: 'tap_me', saveTime: now)];

      await tester.pumpWidget(buildWidget(testRecords));

      await tester.tap(find.byType(HistoryTile));
      await tester.pump();

      expect(tappedKeys, contains('tap_me'));
    });

    testWidgets('section header uses titleMedium style', (tester) async {
      final now = DateTime.now();

      testRecords = [createHistory(key: '1', saveTime: now)];

      await tester.pumpWidget(buildWidget(testRecords));

      final textFinder = find.text('今天');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontWeight, FontWeight.w500);
    });
  });
}
