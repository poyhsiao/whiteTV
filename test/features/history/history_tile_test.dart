import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/widgets/history_tile.dart';

void main() {
  group('HistoryTile episode progress', () {
    testWidgets('displays episode progress as "第 5 集/共 24 集"', (tester) async {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test Video',
        sourceName: 'TestSource',
        playTime: 300,
        totalTime: 600,
        saveTime: DateTime.now(),
        type: 'series',
        currentEpisode: 5,
        totalEpisodes: 24,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HistoryTile(
            history: history,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ));

      expect(find.text('第 5 集/共 24 集'), findsOneWidget);
    });
  });

  group('HistoryTile watched time', () {
    testWidgets('displays formatted watched time', (tester) async {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test Video',
        sourceName: 'TestSource',
        playTime: 300,
        totalTime: 600,
        saveTime: DateTime.now(),
        type: 'movie',
        watchedTime: 5400, // 1h 30m
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HistoryTile(
            history: history,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ));

      expect(find.text('已觀看 1h 30m'), findsOneWidget);
    });
  });

  group('HistoryTile keyboard delete', () {
    testWidgets('has CallbackShortcuts wrapper for keyboard delete', (tester) async {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test Movie',
        sourceName: 'TestSource',
        playTime: 300,
        totalTime: 600,
        saveTime: DateTime.now(),
        type: 'movie',
        watchedTime: 3600,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryTile(
              history: history,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify CallbackShortcuts is present
      expect(find.byType(CallbackShortcuts), findsOneWidget);
    });
  });
}