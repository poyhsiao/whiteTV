import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';

// ponytail: FakeSettingsStore sets state synchronously, bypassing _loadSettings.
// Storage service methods are never called, so we use a minimal const stub.
class FakeSettingsStore extends SettingsStore {
  FakeSettingsStore() : super(const _FakeStorageService()) {
    super.state = const SettingsState(
      timeshiftBufferDuration: 30,
      homeBlocks: {
        'showRecentWatch': true,
        'showLive': true,
        'showCategories': true,
        'showAIRecommend': true,
        'showHotMovies': true,
      },
    );
  }
}

// Methods are never invoked — state is set synchronously in FakeSettingsStore.
// Kept minimal to satisfy interface without 80 lines of boilerplate.
class _FakeStorageService implements SettingsStorageService {
  const _FakeStorageService();
  @override Future<String?> getLunaTVUrl() async => null;
  @override Future<void> saveLunaTVUrl(String url) async {}
  @override Future<String> getThemeMode() async => 'dark';
  @override Future<void> saveThemeMode(String mode) async {}
  @override Future<bool> getAutoPlay() async => true;
  @override Future<void> saveAutoPlay(bool enabled) async {}
  @override Future<String> getDefaultQuality() async => 'auto';
  @override Future<void> saveDefaultQuality(String quality) async {}
  @override Future<bool> getAutoSelectSource() async => true;
  @override Future<void> saveAutoSelectSource(bool enabled) async {}
  @override Future<List<String>> getBlockedSources() async => [];
  @override Future<void> saveBlockedSources(List<String> sources) async {}
  @override Future<Map<String, bool>> getHomeBlocks() async =>
      {'showRecentWatch': true, 'showLive': true, 'showCategories': true,
       'showAIRecommend': true, 'showHotMovies': true};
  @override Future<void> saveHomeBlocks(Map<String, bool> blocks) async {}
  @override Future<List<String>> getTabOrder() async => [];
  @override Future<void> saveTabOrder(List<String> order) async {}
  @override Future<int> getTimeshiftBufferDuration() async => 30;
  @override Future<void> saveTimeshiftBufferDuration(int minutes) async {}
  @override Future<String?> getUsername() async => null;
  @override Future<void> saveUsername(String? username) async {}
  @override Future<String?> getAuthCookie() async => null;
  @override Future<void> saveAuthCookie(String cookie) async {}
  @override Future<void> clearAuthCookie() async {}
  @override Future<bool> getOnboardingComplete() async => false;
  @override Future<void> saveOnboardingComplete(bool complete) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Live TV BDD', () {
    late ProviderContainer container;

    setUp(() async {
      final fakeStore = FakeSettingsStore();
      container = ProviderContainer(
        overrides: [
          settingsStoreProvider.overrideWith((ref) => fakeStore),
        ],
      );
      // Wait for async _loadSettings to finish — use addTearDown-resilient approach
      await Future.delayed(const Duration(milliseconds: 0));
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
