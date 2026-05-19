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
  });
}