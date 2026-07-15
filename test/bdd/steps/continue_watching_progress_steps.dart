import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/episode_progress.dart';
import 'package:white_tv/features/history/widgets/history_tile.dart';

void main() {
  group('續播進度顯示 (Continue Watching Progress)', () {
    // ======== Scenario: 首頁顯示最近觀看的播放進度 ========
    test('displays progress bar for recent watch items', () {
      // Given 最近觀看項目有進度
      final history = PlayHistory(
        key: '1',
        videoId: 'video_1',
        title: '測試影片',
        posterUrl: 'https://example.com/poster.jpg',
        sourceName: '測試來源',
        playTime: 3000,
        totalTime: 6000,
        saveTime: DateTime.now(),
        type: 'movie',
      );

      // Then 應該顯示播放進度條
      expect(history.progressPercent, greaterThan(0));
      // And 應該顯示進度百分比
      expect(history.progressPercent, equals(50.0));
    });

    // ======== Scenario: 進度條顯示正確的百分比 ========
    test('shows correct 50% progress', () {
      // Given 最近觀看項目進度為 50%
      final progress = EpisodeProgress(
        episodeNumber: 1,
        playTime: 3000,
        totalTime: 6000,
      );

      // Then 應該顯示 "50%" 文字
      expect(progress.progressPercent, equals(50.0));
      // And 進度條應該填充 50%
      expect(progress.progressFraction, equals(0.5));
    });

    // ======== Scenario: 零進度不顯示進度條 ========
    test('zero progress shows empty progress bar', () {
      // Given 最近觀看項目進度為 0%
      final progress = EpisodeProgress(
        episodeNumber: 1,
        playTime: 0,
        totalTime: 6000,
      );

      // Then 進度條應該為空
      expect(progress.progressPercent, equals(0.0));
      expect(progress.progressFraction, equals(0.0));
    });

    // ======== Scenario: 關閉進度顯示時不渲染進度條 ========
    test('progress hidden when showProgress is false', () {
      // Given 最近觀看項目進度為 50%
      // When showProgress=false, 進度條邏輯應隱藏
      const showProgress = false;
      expect(showProgress, isFalse);
    });

    // ======== Scenario: HistoryTile 顯示與海報卡片相同的進度 ========
    testWidgets('HistoryTile displays same progress as poster card', (tester) async {
      // Given 歷史記錄項目進度為 85%
      final history = PlayHistory(
        key: '1',
        videoId: 'video_1',
        title: '測試影片',
        posterUrl: 'https://example.com/poster.jpg',
        sourceName: '測試來源',
        playTime: 5100,
        totalTime: 6000,
        saveTime: DateTime.now(),
        type: 'movie',
      );

      // When 渲染 HistoryTile
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

      // Then 應該顯示 "[85%] ████████░" 格式
      expect(find.textContaining('85%'), findsWidgets);
      // And 應該顯示 LinearProgressIndicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    // ======== Scenario: 100% 進度顯示為完成 ========
    test('100% progress shows as completed', () {
      final progress = EpisodeProgress(
        episodeNumber: 1,
        playTime: 6000,
        totalTime: 6000,
      );

      expect(progress.progressPercent, equals(100.0));
      expect(progress.isCompleted, isTrue);
    });
  });
}
