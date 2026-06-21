import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/player_store.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Player Controls BDD', () {
    // 測試 PlayerState 預設值
    test('initial PlayerState has default values', () {
      const state = PlayerState();
      expect(state.videoId, isNull);
      expect(state.isPlaying, isFalse);
      expect(state.isBuffering, isFalse);
      expect(state.currentPosition, equals(Duration.zero));
      expect(state.duration, equals(Duration.zero));
      expect(state.playbackSpeed, equals(1.0));
      expect(state.volume, equals(1.0));
      expect(state.isMuted, isFalse);
      expect(state.isFullscreen, isFalse);
      expect(state.controlsVisible, isTrue);
      expect(state.availableSources, isEmpty);
      expect(state.currentSource, isNull);
    });

    // 測試 copyWith
    test('PlayerState copyWith works correctly', () {
      const state = PlayerState(isPlaying: true);
      final updated = state.copyWith(isPlaying: false);
      expect(updated.isPlaying, isFalse);
      expect(state.isPlaying, isTrue); // original unchanged
    });

    // 測試 copyWith with sources
    test('PlayerState copyWith with sources', () {
      const state = PlayerState();
      const sources = [
        VideoSource(id: 's1', name: 'S1', url: 'http://a.com', latency: 0, isAvailable: true),
        VideoSource(id: 's2', name: 'S2', url: 'http://b.com', latency: 0, isAvailable: true),
      ];
      final updated = state.copyWith(availableSources: sources);
      expect(updated.availableSources.length, equals(2));
    });
  });
}
