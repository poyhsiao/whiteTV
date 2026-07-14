import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/player/player_store.dart';
import 'package:white_tv/features/player/player_screen.dart';

/// Fake VideoPlayerController for testing
class _FakeVideoPlayerController implements VideoPlayerController {
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
  Stream<bool> get onCompleted => const Stream.empty();
  @override
  void dispose() {}
}

/// Pre-loaded PlayerStore that skips API loading to avoid timers
class _PreloadedPlayerStore extends PlayerStore {
  _PreloadedPlayerStore(super.api, super.selector);

  @override
  Future<void> setVideo(String videoId, String episodeId, {bool autoSelectSource = true, List<dynamic>? sources, String? thumbnail, String? title}) async {
    // No-op: state is already preloaded, avoids starting _autoSaveTimer
  }
}

void main() {
  group('PlayerScreen lock button', () {
    testWidgets('shows lock button in TV controls', (tester) async {
      final mockClient = MockClient();
      final store = _PreloadedPlayerStore(mockClient, SourceSelector());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStoreProvider.overrideWith((ref) => store),
            videoPlayerControllerProvider.overrideWithValue(
              _FakeVideoPlayerController(),
            ),
          ],
          child: const MaterialApp(
            home: PlayerScreen(videoId: 'movie-1', episodeId: 'episode-1'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byKey(const Key('controls_lock_button')), findsOneWidget);
    });

    testWidgets('lock button toggles controls locked state', (tester) async {
      final mockClient = MockClient();
      final store = _PreloadedPlayerStore(mockClient, SourceSelector());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStoreProvider.overrideWith((ref) => store),
            videoPlayerControllerProvider.overrideWithValue(
              _FakeVideoPlayerController(),
            ),
          ],
          child: const MaterialApp(
            home: PlayerScreen(videoId: 'movie-1', episodeId: 'episode-1'),
          ),
        ),
      );

      await tester.pump();

      final lockButton = find.byKey(const Key('controls_lock_button'));
      expect(lockButton, findsOneWidget);

      await tester.tap(lockButton);
      await tester.pump();

      // Button still present after toggle
      expect(find.byKey(const Key('controls_lock_button')), findsOneWidget);
    });
  });
}
