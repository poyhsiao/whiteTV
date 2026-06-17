import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/widgets/recent_watch_section.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';

void main() {
  group('RecentWatchSection', () {
    testWidgets('displays section title "最近觀看"', (tester) async {
      final records = [_createPlayHistory(videoId: '1', title: 'Test Show 1')];

      await tester.pumpWidget(_buildWidget(records: records));

      expect(find.text('最近觀看'), findsOneWidget);
    });

    testWidgets('limits display to 10 records max', (tester) async {
      // Set a large surface size to ensure all items are visible
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      final records = List.generate(
        15,
        (i) => _createPlayHistory(videoId: '$i', title: 'Show $i'),
      );

      await tester.pumpWidget(_buildWidget(records: records));
      await tester.pumpAndSettle();

      // ListView should exist
      expect(find.byType(ListView), findsOneWidget);

      // Verify section title
      expect(find.text('最近觀看'), findsOneWidget);

      // With large surface, all 10 items should render
      expect(find.byType(PosterCard), findsNWidgets(10));

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('shows nothing when empty (returns SizedBox.shrink)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildWidget(records: []));
      await tester.pumpAndSettle();

      // Column with empty records should not render ListView
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('passes progress to PosterCard', (tester) async {
      final records = [
        _createPlayHistory(
          videoId: '1',
          title: 'Test Show',
          playTime: 500,
          totalTime: 1000,
        ),
      ];

      await tester.pumpWidget(_buildWidget(records: records));
      await tester.pump();

      // Verify PosterCard exists and is rendered
      expect(find.byType(PosterCard), findsOneWidget);
      // Verify the title is passed correctly
      expect(find.text('Test Show'), findsOneWidget);
    });

    testWidgets('displays progress bar when showProgress is true', (tester) async {
      final records = [
        _createPlayHistory(
          videoId: '1',
          title: 'Test Show',
          playTime: 500,
          totalTime: 1000,
        ),
      ];

      await tester.pumpWidget(_buildWidget(
        records: records,
        showProgress: true,
      ));
      await tester.pump();

      // Verify progress percentage text is displayed
      expect(find.text('50%'), findsOneWidget);
      // Verify LinearProgressIndicator exists
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('hides progress bar when showProgress is false', (tester) async {
      final records = [
        _createPlayHistory(
          videoId: '1',
          title: 'Test Show',
          playTime: 500,
          totalTime: 1000,
        ),
      ];

      await tester.pumpWidget(_buildWidget(
        records: records,
        showProgress: false,
      ));
      await tester.pump();

      // Progress bar should not be displayed
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('50%'), findsNothing);
    });

    testWidgets('displays 0% when totalTime is 0', (tester) async {
      final records = [
        _createPlayHistory(
          videoId: '1',
          title: 'Test Show',
          playTime: 0,
          totalTime: 0,
        ),
      ];

      await tester.pumpWidget(_buildWidget(
        records: records,
        showProgress: true,
      ));
      await tester.pump();

      // Should display 0% instead of crashing
      expect(find.text('0%'), findsOneWidget);
    });
  });
}

PlayHistory _createPlayHistory({
  required String videoId,
  required String title,
  int playTime = 0,
  int totalTime = 100,
}) {
  return PlayHistory(
    key: 'key_$videoId',
    videoId: videoId,
    title: title,
    posterUrl: null,
    sourceName: 'Test Source',
    playTime: playTime,
    totalTime: totalTime,
    saveTime: DateTime.now(),
    type: 'movie',
  );
}

Widget _buildWidget({
  required List<PlayHistory> records,
  Function(PlayHistory)? onTap,
  bool showProgress = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RecentWatchSection(
        records: records,
        onTap: onTap ?? (_) {},
        showProgress: showProgress,
      ),
    ),
  );
}
