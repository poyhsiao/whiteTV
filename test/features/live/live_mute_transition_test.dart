import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

class MockLiveService extends Mock implements LiveService {}

void main() {
  group('Live Mute Transition', () {
    late MockLiveService mockService;
    late LiveStore store;

    setUpAll(() {
      registerFallbackValue(M3uChannel(name: 'fallback', url: 'http://fallback.com'));
    });

    setUp(() {
      mockService = MockLiveService();
      // Setup default mock behavior
      when(() => mockService.loadChannels(any())).thenAnswer((_) async {
        return LiveState.initial().copyWith(
          channels: [
            M3uChannel(name: 'CCTV-1', url: 'http://example.com/1'),
            M3uChannel(name: 'CCTV-2', url: 'http://example.com/2'),
          ],
          status: LiveStatus.loaded,
        );
      });
      when(() => mockService.selectChannel(any())).thenAnswer((inv) async {
        final channel = inv.positionalArguments[0] as M3uChannel;
        return LiveState.initial().copyWith(currentChannel: channel);
      });

      store = LiveStore(mockService);
    });

    test('mute() sets isMuted to true', () {
      store.mute();
      expect(store.state.isMuted, true);
    });

    test('unmute() sets isMuted to false', () {
      store.mute();
      store.unmute();
      expect(store.state.isMuted, false);
    });

    test('nextChannel() mutes before switching', () async {
      await store.loadChannels('');
      expect(store.state.isMuted, false);

      // nextChannel should mute before switching
      store.nextChannel();

      // After switch, isMuted should be true (auto-unmute happens after delay)
      expect(store.state.isMuted, true);
    });
  });
}
