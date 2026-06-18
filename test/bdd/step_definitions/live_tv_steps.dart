import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Live TV BDD', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has no channels', () {
      final state = container.read(liveStoreProvider);
      expect(state.channels, isEmpty);
      expect(state.currentChannel, isNull);
      expect(state.status, equals(LiveStatus.initial));
    });

    test('selectChannel sets current channel', () async {
      final notifier = container.read(liveStoreProvider.notifier);
      const ch = M3uChannel(name: '新聞台', url: 'http://t.com/l1', groupTitle: '新聞');
      await notifier.selectChannel(ch);
      expect(container.read(liveStoreProvider).currentChannel?.name, equals('新聞台'));
    });

    test('handleSignalError sets error state', () {
      final notifier = container.read(liveStoreProvider.notifier);
      notifier.handleSignalError('直播中斷');
      expect(container.read(liveStoreProvider).isSignalError, isTrue);
      expect(container.read(liveStoreProvider).errorMessage, equals('直播中斷'));
    });

    test('clearSignalError resets error state', () {
      final notifier = container.read(liveStoreProvider.notifier);
      notifier.handleSignalError('error');
      notifier.clearSignalError();
      expect(container.read(liveStoreProvider).isSignalError, isFalse);
      expect(container.read(liveStoreProvider).errorMessage, isNull);
    });

    test('mute and unmute toggle', () {
      final notifier = container.read(liveStoreProvider.notifier);
      expect(container.read(liveStoreProvider).isMuted, isFalse);
      notifier.mute();
      expect(container.read(liveStoreProvider).isMuted, isTrue);
      notifier.unmute();
      expect(container.read(liveStoreProvider).isMuted, isFalse);
    });
  });
}
