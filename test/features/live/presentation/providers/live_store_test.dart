import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

class FakeM3uParser implements M3uParser {
  @override
  List<M3uChannel> parse(String content, {String? groupTitle}) => [];

  @override
  List<M3uChannel> searchChannels(String content, {required String query}) => [];
}

class FakeEpgManager implements EpgManager {
  @override
  Future<EpgChannel> fetchEpg(String channelId) async => EpgChannel(id: channelId, name: '', programs: []);

  @override
  Future<EpgProgram?> getCurrentProgram(String channelId) async => null;

  @override
  Future<EpgProgram?> getProgramAtTime(String channelId, DateTime time) async => null;

  @override
  Future<List<EpgProgram>> getProgramsForDay(String channelId, DateTime day) async => [];
}

class FakeSettingsStorageService implements SettingsStorageService {
  @override
  Future<void> saveAuthCookie(String cookie) async {}

  @override
  Future<String?> getAuthCookie() async => null;

  @override
  Future<void> clearAuthCookie() async {}

  @override
  Future<void> saveUsername(String? username) async {}

  @override
  Future<String?> getUsername() async => null;

  @override
  Future<void> saveOnboardingComplete(bool complete) async {}

  @override
  Future<bool> getOnboardingComplete() async => false;

  @override
  Future<void> saveLunaTVUrl(String url) async {}

  @override
  Future<String?> getLunaTVUrl() async => null;

  @override
  Future<void> saveThemeMode(String mode) async {}

  @override
  Future<String> getThemeMode() async => 'dark';

  @override
  Future<void> saveAutoPlay(bool enabled) async {}

  @override
  Future<bool> getAutoPlay() async => true;

  @override
  Future<void> saveDefaultQuality(String quality) async {}

  @override
  Future<String> getDefaultQuality() async => 'auto';

  @override
  Future<void> saveAutoSelectSource(bool enabled) async {}

  @override
  Future<bool> getAutoSelectSource() async => true;

  @override
  Future<void> saveBlockedSources(List<String> sources) async {}

  @override
  Future<List<String>> getBlockedSources() async => [];

  @override
  Future<void> saveHomeBlocks(Map<String, bool> blocks) async {}

  @override
  Future<Map<String, bool>> getHomeBlocks() async => {};

  @override
  Future<void> saveTabOrder(List<String> order) async {}

  @override
  Future<List<String>> getTabOrder() async => [];

  @override
  Future<void> saveTimeshiftBufferDuration(int minutes) async {}

  @override
  Future<int> getTimeshiftBufferDuration() async => 30;
}

class FakeTimeshiftManager implements TimeshiftManager {
  String? lastStartClientBufferChannelId;
  Duration? lastStartClientBufferDuration;
  bool serviceSideSupported = false;
  String? serviceSideStreamUrl;

  void reset() {
    lastStartClientBufferChannelId = null;
    lastStartClientBufferDuration = null;
    serviceSideSupported = false;
    serviceSideStreamUrl = null;
  }

  @override
  Future<TimeshiftController> startTimeshift({
    required String channelId,
    required String streamUrl,
  }) async {
    return TimeshiftController(
      channelId: channelId,
      streamUrl: streamUrl,
      startTime: DateTime.now(),
    );
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<Duration> seek(Duration position) async => position;

  @override
  Future<Duration> fastForward(Duration duration) async => duration;

  @override
  Future<Duration> rewind(Duration duration) async => duration;

  @override
  Future<void> stopTimeshift() async {}

  @override
  bool get isTimeshiftActive => false;

  @override
  Duration get maxTimeshiftDuration => const Duration(days: 7);

  @override
  Future<TimeshiftState> getState() async => const TimeshiftState(
        position: Duration.zero,
        bufferedDuration: Duration.zero,
        isPaused: false,
        isLive: true,
      );

  @override
  Future<bool> isServiceSideSupported(String channelId) async => serviceSideSupported;

  @override
  Future<String?> getServiceSideStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  ) async =>
      serviceSideStreamUrl;

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {
    lastStartClientBufferChannelId = channelId;
    lastStartClientBufferDuration = duration;
  }

  @override
  Future<void> stopClientBuffer() async {}

  @override
  bool get isClientBufferActive => false;

  @override
  Future<File?> getBufferedStream(String channelId, Duration offset) async =>
      null;
}

// Fake LiveService extending LiveService for testing
class FakeLiveService extends LiveService {
  LiveState _state = LiveState.initial();

  FakeLiveService(TimeshiftManager manager) : super(
    m3uParser: FakeM3uParser(),
    epgManager: FakeEpgManager(),
    timeshiftManager: manager,
  );

  @override
  Future<LiveState> loadChannels(String m3uContent) async {
    _state = _state.copyWith(status: LiveStatus.loading);
    // Use same parsing as M3uParserImpl for accurate test
    final lines = m3uContent.split('\n');
    final channels = <M3uChannel>[];
    String? currentExtInf;
    for (var i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed.startsWith('#EXTINF:')) {
        currentExtInf = trimmed;
      } else if (trimmed.isNotEmpty && !trimmed.startsWith('#') && currentExtInf != null) {
        channels.add(M3uChannel.parse(currentExtInf, trimmed));
        currentExtInf = null;
      }
    }
    _state = _state.copyWith(status: LiveStatus.loaded, channels: channels);
    return _state;
  }

  @override
  Future<LiveState> selectChannel(M3uChannel channel) async {
    _state = _state.copyWith(currentChannel: channel, status: LiveStatus.loaded);
    return _state;
  }

  @override
  Future<LiveState> startTimeshift(M3uChannel channel, Duration offset) async {
    _state = _state.copyWith(
      status: LiveStatus.timeshift,
      currentChannel: channel,
      timeshiftPosition: offset,
    );
    return _state;
  }

  @override
  Future<LiveState> stopTimeshift() async {
    _state = _state.copyWith(status: LiveStatus.loaded, clearTimeshiftPosition: true);
    return _state;
  }

  @override
  LiveState handleSignalError(String message) {
    _state = _state.copyWith(isSignalError: true, errorMessage: message);
    return _state;
  }

  @override
  LiveState clearSignalError() {
    _state = _state.copyWith(isSignalError: false, clearErrorMessage: true);
    return _state;
  }

  @override
  List<M3uChannel> searchChannels(String query) {
    final queryLower = query.toLowerCase();
    return _state.channels.where((c) => c.name.toLowerCase().contains(queryLower)).toList();
  }

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {
    // Delegate to manager so FakeTimeshiftManager can track it
    await timeshiftManager.startClientBuffer(channelId, duration);
  }

  @override
  Future<void> stopClientBuffer() async {}
}

void main() {
  group('LiveStore', () {
    late ProviderContainer container;

    setUp(() {
      // Override liveStoreProvider to use fake LiveService directly,
      // bypassing SettingsStore dependency
      final fakeTimeshiftManager = FakeTimeshiftManager();
      final fakeService = FakeLiveService(fakeTimeshiftManager);
      const fakeSettings = SettingsState();

      container = ProviderContainer(
        overrides: [
          liveStoreProvider.overrideWith(
            (ref) => LiveStore(fakeService, fakeSettings, fakeTimeshiftManager),
          ),
        ],
      );
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

    test('clearSignalError clears isSignalError and errorMessage when error was set', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      // First set an error
      container.read(liveStoreProvider.notifier).handleSignalError('Signal lost');
      var state = container.read(liveStoreProvider);
      expect(state.isSignalError, isTrue);
      expect(state.errorMessage, 'Signal lost');

      // Then clear it
      container.read(liveStoreProvider.notifier).clearSignalError();
      state = container.read(liveStoreProvider);
      expect(state.isSignalError, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('clearSignalError does nothing when no error is set', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      // Ensure no error state exists
      final stateBefore = container.read(liveStoreProvider);
      expect(stateBefore.isSignalError, isFalse);

      // Clear without having set an error
      container.read(liveStoreProvider.notifier).clearSignalError();

      final stateAfter = container.read(liveStoreProvider);
      expect(stateAfter.isSignalError, isFalse);
      expect(stateAfter.errorMessage, isNull);
    });

    test('searchChannels returns matching channels by name', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel One",Channel One
https://example.com/ch1.m3u8
#EXTINF:-1 tvg-name="Channel Two",Channel Two
https://example.com/ch2.m3u8
#EXTINF:-1 tvg-name="Other Channel",Other Channel
https://example.com/other.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      final results = container.read(liveStoreProvider.notifier).searchChannels('One');

      expect(results.length, 1);
      expect(results.first.name, 'Channel One');
    });

    test('searchChannels returns empty list when no match', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel One",Channel One
https://example.com/ch1.m3u8
#EXTINF:-1 tvg-name="Channel Two",Channel Two
https://example.com/ch2.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      final results = container.read(liveStoreProvider.notifier).searchChannels('XYZ');

      expect(results, isEmpty);
    });

    test('searchChannels case-insensitive search', () async {
      const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Discovery Channel",Discovery Channel
https://example.com/discovery.m3u8
#EXTINF:-1 tvg-name="National Geographic",National Geographic
https://example.com/natgeo.m3u8
''';

      await container.read(liveStoreProvider.notifier).loadChannels(testM3uContent);

      final resultsLower = container.read(liveStoreProvider.notifier).searchChannels('discovery');
      final resultsUpper = container.read(liveStoreProvider.notifier).searchChannels('DISCOVERY');
      final resultsMixed = container.read(liveStoreProvider.notifier).searchChannels('Discovery');

      expect(resultsLower.length, 1);
      expect(resultsUpper.length, 1);
      expect(resultsMixed.length, 1);
      expect(resultsLower.first.name, 'Discovery Channel');
      expect(resultsUpper.first.name, 'Discovery Channel');
      expect(resultsMixed.first.name, 'Discovery Channel');
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

    group('playChannel', () {
      late FakeTimeshiftManager fakeTimeshiftManager;

      setUp(() {
        fakeTimeshiftManager = FakeTimeshiftManager();
      });

      test('calls startClientBuffer with correct channelId and duration', () async {
        const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-id="ch123" tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

        final fakeService = FakeLiveService(fakeTimeshiftManager);
        const fakeSettings = SettingsState(timeshiftBufferDuration: 30);
        final containerForTest = ProviderContainer(
          overrides: [
            liveStoreProvider.overrideWith(
              (ref) => LiveStore(fakeService, fakeSettings, fakeTimeshiftManager),
            ),
          ],
        );

        await containerForTest.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
        final channels = containerForTest.read(liveStoreProvider).channels;

        await containerForTest.read(liveStoreProvider.notifier).playChannel(channels.first);

        expect(fakeTimeshiftManager.lastStartClientBufferChannelId, 'ch123');
        expect(fakeTimeshiftManager.lastStartClientBufferDuration, const Duration(minutes: 30));

        containerForTest.dispose();
      });

      test('falls back to client-side selectChannel when service-side not supported', () async {
        const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

        // Service-side NOT supported
        fakeTimeshiftManager.serviceSideSupported = false;

        final fakeService = FakeLiveService(fakeTimeshiftManager);
        const fakeSettings = SettingsState(timeshiftBufferDuration: 30);
        final containerForTest = ProviderContainer(
          overrides: [
            liveStoreProvider.overrideWith(
              (ref) => LiveStore(fakeService, fakeSettings, fakeTimeshiftManager),
            ),
          ],
        );

        await containerForTest.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
        final channels = containerForTest.read(liveStoreProvider).channels;

        await containerForTest.read(liveStoreProvider.notifier).playChannel(channels.first);

        // Should call startClientBuffer
        expect(fakeTimeshiftManager.lastStartClientBufferChannelId, isNotNull);
        // Falls back to selectChannel → status = loaded
        final state = containerForTest.read(liveStoreProvider);
        expect(state.status, LiveStatus.loaded);
        expect(state.currentChannel, channels.first);

        containerForTest.dispose();
      });

      test('uses service-side timeshift when supported', () async {
        const testM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-id="ch123" tvg-name="Test Channel",Test Channel
https://example.com/test.m3u8
''';

        // Service-side IS supported
        fakeTimeshiftManager.serviceSideSupported = true;
        fakeTimeshiftManager.serviceSideStreamUrl = 'https://service-side-stream.example.com/ch123';

        final fakeService = FakeLiveService(fakeTimeshiftManager);
        const fakeSettings = SettingsState(timeshiftBufferDuration: 30);
        final containerForTest = ProviderContainer(
          overrides: [
            liveStoreProvider.overrideWith(
              (ref) => LiveStore(fakeService, fakeSettings, fakeTimeshiftManager),
            ),
          ],
        );

        await containerForTest.read(liveStoreProvider.notifier).loadChannels(testM3uContent);
        final channels = containerForTest.read(liveStoreProvider).channels;

        await containerForTest.read(liveStoreProvider.notifier).playChannel(channels.first);

        // Should check service-side support
        // Falls back to startTimeshift since streamUrl is not null
        final state = containerForTest.read(liveStoreProvider);
        expect(state.status, LiveStatus.timeshift);
        expect(state.currentChannel, channels.first);

        containerForTest.dispose();
      });
    });
  });
}