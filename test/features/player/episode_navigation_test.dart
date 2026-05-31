import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/widgets/episode_navigation.dart';

void main() {
  group('EpisodeNavigation', () {
    testWidgets('shows previous and next buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeNavigation(
              currentEpisode: 5,
              totalEpisodes: 10,
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });

    testWidgets('previous button disabled on first episode', (tester) async {
      bool previousPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeNavigation(
              currentEpisode: 1,
              totalEpisodes: 10,
              onPrevious: () => previousPressed = true,
              onNext: () {},
            ),
          ),
        ),
      );

      // Find the previous IconButton and verify it's disabled
      final previousButton = find.ancestor(
        of: find.byIcon(Icons.skip_previous),
        matching: find.byType(IconButton),
      );
      expect(previousButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(previousButton);
      expect(iconButton.onPressed, isNull);

      // Tap should not trigger callback
      await tester.tap(find.byIcon(Icons.skip_previous));
      expect(previousPressed, false);
    });

    testWidgets('next button disabled on last episode', (tester) async {
      bool nextPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeNavigation(
              currentEpisode: 10,
              totalEpisodes: 10,
              onPrevious: () {},
              onNext: () => nextPressed = true,
            ),
          ),
        ),
      );

      // Find the next IconButton and verify it's disabled
      final nextButton = find.ancestor(
        of: find.byIcon(Icons.skip_next),
        matching: find.byType(IconButton),
      );
      expect(nextButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(nextButton);
      expect(iconButton.onPressed, isNull);

      // Tap should not trigger callback
      await tester.tap(find.byIcon(Icons.skip_next));
      expect(nextPressed, false);
    });

    testWidgets('displays episode number in X/Y format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeNavigation(
              currentEpisode: 5,
              totalEpisodes: 10,
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('5/10'), findsOneWidget);
    });

    testWidgets('previous button enabled when not on first episode', (
      tester,
    ) async {
      bool previousPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeNavigation(
              currentEpisode: 5,
              totalEpisodes: 10,
              onPrevious: () => previousPressed = true,
              onNext: () {},
            ),
          ),
        ),
      );

      final previousButton = find.ancestor(
        of: find.byIcon(Icons.skip_previous),
        matching: find.byType(IconButton),
      );
      final iconButton = tester.widget<IconButton>(previousButton);
      expect(iconButton.onPressed, isNotNull);

      await tester.tap(find.byIcon(Icons.skip_previous));
      expect(previousPressed, true);
    });

    testWidgets('next button enabled when not on last episode', (tester) async {
      bool nextPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeNavigation(
              currentEpisode: 5,
              totalEpisodes: 10,
              onPrevious: () {},
              onNext: () => nextPressed = true,
            ),
          ),
        ),
      );

      final nextButton = find.ancestor(
        of: find.byIcon(Icons.skip_next),
        matching: find.byType(IconButton),
      );
      final iconButton = tester.widget<IconButton>(nextButton);
      expect(iconButton.onPressed, isNotNull);

      await tester.tap(find.byIcon(Icons.skip_next));
      expect(nextPressed, true);
    });
  });
}
