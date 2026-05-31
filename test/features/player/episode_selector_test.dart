import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/widgets/episode_selector.dart';

void main() {
  group('EpisodeSelector', () {
    testWidgets('shows episode button with correct text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeSelector(
              currentEpisode: 5,
              totalEpisodes: 10,
              onEpisodeSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('第 5 集'), findsOneWidget);
    });

    testWidgets('opens episode list dialog on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeSelector(
              currentEpisode: 3,
              totalEpisodes: 10,
              onEpisodeSelected: (_) {},
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('第 3 集'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows GridView of episodes in dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeSelector(
              currentEpisode: 5,
              totalEpisodes: 10,
              onEpisodeSelected: (_) {},
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('第 5 集'));
      await tester.pumpAndSettle();

      // Verify GridView exists in dialog
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('calls onEpisodeSelected when episode tapped', (tester) async {
      int? selectedEpisode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeSelector(
              currentEpisode: 5,
              totalEpisodes: 10,
              onEpisodeSelected: (episode) {
                selectedEpisode = episode;
              },
            ),
          ),
        ),
      );

      // Tap the button to open dialog
      await tester.tap(find.text('第 5 集'));
      await tester.pumpAndSettle();

      // Find and tap episode 3 in the grid
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(selectedEpisode, 3);
    });

    testWidgets('highlights current episode with accent color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeSelector(
              currentEpisode: 5,
              totalEpisodes: 10,
              onEpisodeSelected: (_) {},
            ),
          ),
        ),
      );

      // Tap the button to open dialog
      await tester.tap(find.text('第 5 集'));
      await tester.pumpAndSettle();

      // Find the container with accent color for episode 5
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundAccentContainer = false;

      for (final container in containers) {
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.color == const Color(0xFFE6A23C)) {
          foundAccentContainer = true;
          break;
        }
      }

      expect(foundAccentContainer, true);
    });
  });
}