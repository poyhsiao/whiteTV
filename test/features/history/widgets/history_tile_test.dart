import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/widgets/history_tile.dart';

void main() {
  late PlayHistory testHistory;

  setUp(() {
    testHistory = PlayHistory(
      key: 'lovedan+12345',
      videoId: '12345',
      title: '測試影片',
      posterUrl: 'https://example.com/poster.jpg',
      sourceName: '量子資源',
      currentEpisode: 5,
      totalEpisodes: 24,
      playTime: 1800,
      totalTime: 3600,
      saveTime: DateTime.now(),
      type: 'tv',
    );
  });

  group('HistoryTile', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: testHistory,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('測試影片'), findsOneWidget);
    });

    testWidgets('displays progress percentage (50%)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: testHistory,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('displays episode info for tv type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: testHistory,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('第5集/共24集'), findsOneWidget);
    });

    testWidgets('does NOT display episode info for movie type', (tester) async {
      final movieHistory = PlayHistory(
        key: 'lovedan+12345',
        videoId: '12345',
        title: '測試影片',
        posterUrl: 'https://example.com/poster.jpg',
        sourceName: '量子資源',
        currentEpisode: null,
        totalEpisodes: null,
        playTime: 1800,
        totalTime: 3600,
        saveTime: DateTime.now(),
        type: 'movie',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: movieHistory,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('第5集/共24集'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: testHistory,
              onTap: () => tapped = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onDelete on long press', (tester) async {
      var deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: testHistory,
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });
  });
}
