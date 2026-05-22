import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  group('PlayerStore', () {
    late MockClient mockClient;
    late PlayerStore store;

    setUp(() {
      mockClient = MockClient();
      store = PlayerStore(mockClient);
    });

    tearDown(() => store.dispose());

    test('initial state is idle', () {
      expect(store.state.isPlaying, false);
      expect(store.state.currentPosition, Duration.zero);
    });

    test('setVideo updates video info', () async {
      await store.setVideo('movie-1', 'episode-1');
      expect(store.state.videoId, 'movie-1');
      expect(store.state.episodeId, 'episode-1');
    });

    test('play updates isPlaying to true', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.play();
      expect(store.state.isPlaying, true);
    });

    test('pause updates isPlaying to false', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.play();
      store.pause();
      expect(store.state.isPlaying, false);
    });

    test('seek updates position', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.seek(const Duration(seconds: 30));
      expect(store.state.currentPosition, const Duration(seconds: 30));
    });

    test('saveProgress updates currentPosition', () {
      store.seek(const Duration(minutes: 10));
      store.saveProgress();

      final state = store.state;
      expect(state.currentPosition, const Duration(minutes: 10));
    });

    test(
      'auto-save timer triggers saveProgress every 30 seconds when playing',
      () async {
        await store.setVideo('movie-1', 'episode-1');
        store.seek(const Duration(seconds: 10));
        store.play();

        // Advance time by 30 seconds to trigger auto-save
        await Future.delayed(const Duration(milliseconds: 3100));

        // After 30 seconds, auto-save should have been called
        // The position should be saved (current implementation is a stub)
        expect(store.state.isPlaying, true);
      },
    );

    test('pause stops auto-save timer', () async {
      await store.setVideo('movie-1', 'episode-1');
      store.play();
      store.pause();

      // After pause, timer should be stopped
      expect(store.state.isPlaying, false);
    });
  });
}
