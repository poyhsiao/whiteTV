import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  group('PlayerStore 自動切換', () {
    late MockClient mockClient;
    late SourceSelector sourceSelector;
    late PlayerStore store;

    setUp(() {
      mockClient = MockClient();
      sourceSelector = SourceSelector();
      store = PlayerStore(mockClient, sourceSelector);
    });

    tearDown(() => store.dispose());

    test('setBuffering 超時後觸發自動切換', () async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
      ];

      await store.setVideo('video1', 'ep1');
      store.play();
      store.setBuffering(true);

      // 模擬超時（11秒，超過 10 秒限制）
      await Future.delayed(const Duration(seconds: 11));

      // 驗證 autoSwitchCount 增加
      expect(store.state.autoSwitchCount, 1);
    });

    test('setBuffering 未超時則不觸發自動切換', () async {
      await store.setVideo('video1', 'ep1');
      store.play();
      store.setBuffering(true);

      // 只等待 5 秒，未超時
      await Future.delayed(const Duration(seconds: 5));

      // 驗證 autoSwitchCount 仍為 0
      expect(store.state.autoSwitchCount, 0);
    });
  });
}