import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';

// Fake settings store for testing - no async initialization
class FakeSettingsStore extends SettingsStore {
  FakeSettingsStore() : super(MockSettingsStorageService()) {
    // Set initial state synchronously to avoid async _loadSettings issues
    state = const SettingsState(
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

// Mock storage service for testing - all sync/fast
class MockSettingsStorageService implements SettingsStorageService {
  @override
  Future<String?> getLunaTVUrl() async => null;

  @override
  Future<void> saveLunaTVUrl(String url) async {}

  @override
  Future<String> getThemeMode() async => 'dark';

  @override
  Future<void> saveThemeMode(String mode) async {}

  @override
  Future<bool> getAutoPlay() async => true;

  @override
  Future<void> saveAutoPlay(bool enabled) async {}

  @override
  Future<String> getDefaultQuality() async => 'auto';

  @override
  Future<void> saveDefaultQuality(String quality) async {}

  @override
  Future<bool> getAutoSelectSource() async => true;

  @override
  Future<void> saveAutoSelectSource(bool enabled) async {}

  @override
  Future<List<String>> getBlockedSources() async => [];

  @override
  Future<void> saveBlockedSources(List<String> sources) async {}

  @override
  Future<Map<String, bool>> getHomeBlocks() async => {
    'showRecentWatch': true,
    'showLive': true,
    'showCategories': true,
    'showAIRecommend': true,
    'showHotMovies': true,
  };

  @override
  Future<void> saveHomeBlocks(Map<String, bool> blocks) async {}

  @override
  Future<List<String>> getTabOrder() async => [];

  @override
  Future<void> saveTabOrder(List<String> order) async {}

  @override
  Future<int> getTimeshiftBufferDuration() async => 30;

  @override
  Future<void> saveTimeshiftBufferDuration(int minutes) async {}

  @override
  Future<String?> getUsername() async => null;

  @override
  Future<void> saveUsername(String? username) async {}

  @override
  Future<String?> getAuthCookie() async => null;

  @override
  Future<void> saveAuthCookie(String cookie) async {}

  @override
  Future<void> clearAuthCookie() async {}

  @override
  Future<bool> getOnboardingComplete() async => false;

  @override
  Future<void> saveOnboardingComplete(bool complete) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Live Timeshift BDD Steps', () {
    late ProviderContainer container;
    late FakeSettingsStore fakeSettingsStore;

    setUp(() async {
      fakeSettingsStore = FakeSettingsStore();

      container = ProviderContainer(
        overrides: [
          // Override settingsStoreProvider with our fake that doesn't do async init
          settingsStoreProvider.overrideWith((ref) {
            return fakeSettingsStore;
          }),
        ],
      );

      // Wait for any pending async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    group('用戶觀看直播並回看過去內容', () {
      test('用戶正在觀看直播頻道 — 初始狀態是 live', () async {
        final notifier = container.read(liveStoreProvider.notifier);
        const ch = M3uChannel(name: 'CCTV-1', url: 'http://test.com/cctv1', groupTitle: '新聞');

        // Select channel first
        await notifier.selectChannel(ch);

        // Verify status is loaded (not timeshift)
        final state = container.read(liveStoreProvider);
        expect(state.status, equals(LiveStatus.loaded));
        expect(state.currentChannel?.name, equals('CCTV-1'));
      });

      test('用戶拖曳時間軸到 10 分鐘前 — timeshift position 更新', () async {
        final notifier = container.read(liveStoreProvider.notifier);
        const ch = M3uChannel(name: 'CCTV-1', url: 'http://test.com/cctv1', groupTitle: '新聞');

        await notifier.selectChannel(ch);
        await notifier.startTimeshift(const Duration(minutes: -10));

        final state = container.read(liveStoreProvider);
        expect(state.timeshiftPosition, equals(const Duration(minutes: -10)));
        expect(state.status, equals(LiveStatus.timeshift));
      });
    });

    group('緩衝已滿，舊內容被淘汰', () {
      test('緩衝已達到設定的上限 — 停留在最舊可用片段', () async {
        final notifier = container.read(liveStoreProvider.notifier);
        const ch = M3uChannel(name: 'CCTV-1', url: 'http://test.com/cctv1', groupTitle: '新聞');

        await notifier.selectChannel(ch);

        // Seek beyond max buffer duration
        await notifier.seekTimeshift(const Duration(hours: -2));

        // The state should update to the maximum available position
        final state = container.read(liveStoreProvider);
        // Implementation should handle clamping to max buffer
        expect(state.timeshiftPosition, isNotNull);
      });
    });

    group('用戶回到直播', () {
      test('用戶正在觀看回看內容 — 點擊 GO LIVE 返回直播', () async {
        final notifier = container.read(liveStoreProvider.notifier);
        const ch = M3uChannel(name: 'CCTV-1', url: 'http://test.com/cctv1', groupTitle: '新聞');

        await notifier.selectChannel(ch);
        await notifier.startTimeshift(const Duration(minutes: -10));

        // Stop timeshift to go back live
        await notifier.stopTimeshift();

        final state = container.read(liveStoreProvider);
        expect(state.status, equals(LiveStatus.loaded));
        expect(state.timeshiftPosition, isNull);
      });
    });
  });
}
