import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  group('Auto-Play Next Episode — UI_UX.md §13.1 + §11.2', () {
    late MockClient mockClient;
    late SourceSelector sourceSelector;
    late PlayerStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockClient = MockClient();
      sourceSelector = SourceSelector();
      await sourceSelector.loadBlockedSources();
      store = PlayerStore(mockClient, sourceSelector);
    });

    tearDown(() => store.dispose());

    test('nextEpisode advances to next episode when not at last', () async {
      await store.setVideo('series-1', 'episode-1');
      store.setTotalEpisodes(5);
      store.setCurrentEpisode(1);

      store.nextEpisode();

      expect(store.state.currentEpisode, 2);
    });

    test('nextEpisode does nothing when at last episode', () async {
      await store.setVideo('series-1', 'episode-5');
      store.setTotalEpisodes(5);
      store.setCurrentEpisode(5);

      store.nextEpisode();

      expect(store.state.currentEpisode, 5);
    });

    test('previousEpisode goes to previous when not at first', () async {
      await store.setVideo('series-1', 'episode-3');
      store.setTotalEpisodes(5);
      store.setCurrentEpisode(3);

      store.previousEpisode();

      expect(store.state.currentEpisode, 2);
    });

    test('previousEpisode does nothing when at first episode', () async {
      await store.setVideo('series-1', 'episode-1');
      store.setTotalEpisodes(5);
      store.setCurrentEpisode(1);

      store.previousEpisode();

      expect(store.state.currentEpisode, 1);
    });

    // ── Auto-play integration ────────────────────────────────────────────────
    // These tests verify the full auto-play flow:
    // 1. PlayerStore receives autoPlay setting (from SettingsStore)
    // 2. When handleEpisodeComplete is called:
    //    - if autoPlay=true and not last → auto nextEpisode + play
    //    - if autoPlay=false → do nothing
    //
    // Currently handleEpisodeComplete() does NOT exist → tests FAIL (Red)

    test(
      'handleEpisodeComplete auto-plays next when autoPlay=true (NOT last episode)',
      () async {
        // Arrange: series with 5 episodes, currently on episode 2
        await store.setVideo('series-1', 'episode-2');
        store.setTotalEpisodes(5);
        store.setCurrentEpisode(2);

        // Act: episode finishes → call handleEpisodeComplete with autoPlay=true
        store.handleEpisodeComplete(autoPlay: true);

        // Assert: should auto-advance to episode 3 and keep playing
        expect(store.state.currentEpisode, 3);
      },
    );

    test(
      'handleEpisodeComplete does NOT auto-play when autoPlay=false',
      () async {
        await store.setVideo('series-1', 'episode-2');
        store.setTotalEpisodes(5);
        store.setCurrentEpisode(2);

        store.handleEpisodeComplete(autoPlay: false);

        // Should stay on same episode
        expect(store.state.currentEpisode, 2);
      },
    );

    test(
      'handleEpisodeComplete does NOT auto-play on last episode (even with autoPlay=true)',
      () async {
        await store.setVideo('series-1', 'episode-5');
        store.setTotalEpisodes(5);
        store.setCurrentEpisode(5);

        store.handleEpisodeComplete(autoPlay: true);

        // Must stay on last episode — no overflow
        expect(store.state.currentEpisode, 5);
      },
    );

    test(
      'handleEpisodeComplete plays after auto-advancing (isPlaying=true after auto-next)',
      () async {
        await store.setVideo('series-1', 'episode-2');
        store.setTotalEpisodes(5);
        store.setCurrentEpisode(2);
        store.pause(); // was paused at end of episode

        store.handleEpisodeComplete(autoPlay: true);

        // After auto-next, should resume playing automatically
        expect(store.state.isPlaying, true);
      },
    );
  });
}
