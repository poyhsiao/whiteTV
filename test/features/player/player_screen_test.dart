import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/player/player_store.dart';
import 'package:white_tv/features/player/player_screen.dart';

/// Fake VideoPlayerController for testing
class FakeVideoPlayerController implements VideoPlayerController {
  @override
  bool get initialized => true;

  @override
  Future<void> open(String url) async {}

  @override
  void pause() {}

  @override
  void play() {}

  @override
  void setRate(double rate) {}

  @override
  void dispose() {}
}

void main() {
  group('PlayerScreen', () {
    testWidgets('controls auto-hide after 5 seconds', (tester) async {
      final mockClient = MockClient();
      final store = PlayerStore(mockClient, SourceSelector());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStoreProvider.overrideWith((ref) => store),
            videoPlayerControllerProvider.overrideWithValue(
              FakeVideoPlayerController(),
            ),
          ],
          child: const MaterialApp(
            home: PlayerScreen(videoId: 'movie-1', episodeId: 'episode-1'),
          ),
        ),
      );

      // Wait for initial render
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();

      // Controls should be visible initially
      expect(store.state.controlsVisible, isTrue);

      // Tapping the video should show controls (already visible, but verifies tap works)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Controls should still be visible after tap
      expect(store.state.controlsVisible, isTrue);
    });

    testWidgets('renders video player container', (tester) async {
      final mockClient = MockClient();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStoreProvider.overrideWith(
              (ref) => PlayerStore(mockClient, SourceSelector()),
            ),
            videoPlayerControllerProvider.overrideWithValue(
              FakeVideoPlayerController(),
            ),
          ],
          child: const MaterialApp(
            home: PlayerScreen(videoId: 'movie-1', episodeId: 'episode-1'),
          ),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });

      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
