import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  group('Player BDD', () {
    test('PlayerState default values', () {
      final state = PlayerState();
      expect(state.isPlaying, isFalse);
      expect(state.currentPosition, equals(Duration.zero));
    });

    test('PlayerState with video', () {
      const state = PlayerState(
        videoId: 'test123',
        isPlaying: true,
        currentPosition: Duration(seconds: 100),
      );
      
      expect(state.videoId, equals('test123'));
      expect(state.isPlaying, isTrue);
      expect(state.currentPosition.inSeconds, equals(100));
    });
  });
}
