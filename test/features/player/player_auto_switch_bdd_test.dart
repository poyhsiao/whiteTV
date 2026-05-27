import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  group('多來源自動切換 BDD 場景', () {
    late MockClient mockClient;
    late SourceSelector sourceSelector;
    late PlayerStore store;

    setUp(() {
      mockClient = MockClient();
      sourceSelector = SourceSelector();
      store = PlayerStore(mockClient, sourceSelector);
    });

    tearDown(() => store.dispose());

    test('播放錯誤時 autoSwitchCount 增加', () async {
      await store.setVideo('video1', 'ep1');
      store.play();

      store.onPlaybackError(const PlaybackError(message: '解析失敗', isTimeout: false));

      expect(store.state.autoSwitchCount, 1);
    });

    test('切換後新來源是可用來源之一', () async {
      await store.setVideo('video1', 'ep1');
      store.play();

      final originalSource = store.state.source;
      store.onPlaybackError(const PlaybackError(message: '解析失敗', isTimeout: false));

      final newSource = store.state.source;
      // 來源應該已經切換
      expect(newSource, isNot(equals(originalSource)));
    });
  });
}