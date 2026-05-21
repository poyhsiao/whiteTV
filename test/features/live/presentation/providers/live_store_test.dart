import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';

void main() {
  group('LiveStore', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(liveStoreProvider);

      expect(state.status, LiveStatus.initial);
      expect(state.channels, isEmpty);
      expect(state.currentChannel, isNull);
    });

    test('loadChannels updates state to loading then loaded', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
      final state = container.read(liveStoreProvider);

      expect(state.status, LiveStatus.loaded);
      expect(state.channels, isNotEmpty);
    });

    test('selectChannel updates currentChannel', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      final channels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(channels.first);

      final state = container.read(liveStoreProvider);
      expect(state.currentChannel, channels.first);
    });

    test('startTimeshift transitions to timeshift status', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      final channels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(channels.first);
      await container.read(liveStoreProvider.notifier).startTimeshift(const Duration(minutes: -10));

      final state = container.read(liveStoreProvider);
      expect(state.status, LiveStatus.timeshift);
    });

    test('stopTimeshift returns to loaded status', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      final channels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(channels.first);
      await container.read(liveStoreProvider.notifier).startTimeshift(const Duration(minutes: -10));
      await container.read(liveStoreProvider.notifier).stopTimeshift();

      final state = container.read(liveStoreProvider);
      expect(state.status, LiveStatus.loaded);
    });

    test('handleSignalError sets isSignalError true', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
      container.read(liveStoreProvider.notifier).handleSignalError('Signal lost');

      final state = container.read(liveStoreProvider);
      expect(state.isSignalError, isTrue);
      expect(state.errorMessage, 'Signal lost');
    });

    test('nextChannel navigates to next channel', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel 1",Channel 1
https://example.com/ch1.m3u8
#EXTINF:-1 tvg-name="Channel 2",Channel 2
https://example.com/ch2.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
      final initialChannels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(initialChannels.first);

      await container.read(liveStoreProvider.notifier).nextChannel();

      final state = container.read(liveStoreProvider);
      expect(state.currentChannel?.name, 'Channel 2');
    });

    test('previousChannel navigates to previous channel', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel 1",Channel 1
https://example.com/ch1.m3u8
#EXTINF:-1 tvg-name="Channel 2",Channel 2
https://example.com/ch2.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
      final channels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(channels.last);

      await container.read(liveStoreProvider.notifier).previousChannel();

      final state = container.read(liveStoreProvider);
      expect(state.currentChannel?.name, 'Channel 1');
    });

    test('togglePlayPause exits timeshift mode', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
      final channels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(channels.first);
      await container.read(liveStoreProvider.notifier).startTimeshift(const Duration(minutes: -5));

      await container.read(liveStoreProvider.notifier).togglePlayPause();

      final state = container.read(liveStoreProvider);
      expect(state.status, LiveStatus.loaded);
    });

    test('seekTimeshift updates timeshift position', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
      final channels = container.read(liveStoreProvider).channels;
      await container.read(liveStoreProvider.notifier).selectChannel(channels.first);
      await container.read(liveStoreProvider.notifier).startTimeshift(const Duration(minutes: -5));

      await container.read(liveStoreProvider.notifier).seekTimeshift(const Duration(minutes: -10));

      final state = container.read(liveStoreProvider);
      expect(state.timeshiftPosition, const Duration(minutes: -10));
    });
  });
}