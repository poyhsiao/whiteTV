import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

class FakeSettingsStorageService implements SettingsStorageService {
  String? _lunaTVUrl;
  String _themeMode = 'dark';
  bool _autoPlay = true;
  String _defaultQuality = 'auto';
  bool _autoSelectSource = true;
  List<String> _blockedSources = [];
  Map<String, bool> _homeBlocks = {};
  List<String> _tabOrder = [];
  int _timeshiftBufferDuration = 30;

  @override
  Future<void> saveLunaTVUrl(String url) async => _lunaTVUrl = url;

  @override
  Future<String?> getLunaTVUrl() async => _lunaTVUrl;

  @override
  Future<void> saveThemeMode(String mode) async => _themeMode = mode;

  @override
  Future<String> getThemeMode() async => _themeMode;

  @override
  Future<void> saveAutoPlay(bool enabled) async => _autoPlay = enabled;

  @override
  Future<bool> getAutoPlay() async => _autoPlay;

  @override
  Future<void> saveDefaultQuality(String quality) async =>
      _defaultQuality = quality;

  @override
  Future<String> getDefaultQuality() async => _defaultQuality;

  @override
  Future<void> saveAutoSelectSource(bool enabled) async =>
      _autoSelectSource = enabled;

  @override
  Future<bool> getAutoSelectSource() async => _autoSelectSource;

  @override
  Future<void> saveBlockedSources(List<String> sources) async =>
      _blockedSources = sources;

  @override
  Future<List<String>> getBlockedSources() async => _blockedSources;

  @override
  Future<void> saveHomeBlocks(Map<String, bool> blocks) async =>
      _homeBlocks = blocks;

  @override
  Future<Map<String, bool>> getHomeBlocks() async => _homeBlocks;

  @override
  Future<void> saveTabOrder(List<String> order) async => _tabOrder = order;

  @override
  Future<List<String>> getTabOrder() async => _tabOrder;

  @override
  Future<void> saveOnboardingComplete(bool complete) async {}

  @override
  Future<bool> getOnboardingComplete() async => false;

  @override
  Future<void> saveUsername(String? username) async {}

  @override
  Future<String?> getUsername() async => null;

  @override
  Future<void> saveAuthCookie(String cookie) async {}

  @override
  Future<String?> getAuthCookie() async => null;

  @override
  Future<void> clearAuthCookie() async {}

  @override
  Future<int> getTimeshiftBufferDuration() async => _timeshiftBufferDuration;

  @override
  Future<void> saveTimeshiftBufferDuration(int minutes) async {
    _timeshiftBufferDuration = minutes;
  }
}

void main() {
  group('SettingsState', () {
    test('has correct default values', () {
      const state = SettingsState();
      expect(state.themeMode, 'dark');
      expect(state.autoPlay, true);
      expect(state.defaultQuality, 'auto');
      expect(state.autoSelectSource, true);
      expect(state.blockedSources, isEmpty);
      expect(state.homeBlocks, isEmpty);
      expect(state.tabOrder, isEmpty);
      expect(state.timeshiftBufferDuration, 30);
    });

    test('copyWith creates new instance with updated values', () {
      const state = SettingsState();
      final updated = state.copyWith(themeMode: 'light', autoPlay: false);
      expect(updated.themeMode, 'light');
      expect(updated.autoPlay, false);
      expect(updated.defaultQuality, 'auto');
    });

    test('themeModeEnum returns correct ThemeMode', () {
      const darkState = SettingsState(themeMode: 'dark');
      expect(darkState.themeModeEnum, ThemeMode.dark);

      const lightState = SettingsState(themeMode: 'light');
      expect(lightState.themeModeEnum, ThemeMode.light);

      const systemState = SettingsState(themeMode: 'system');
      expect(systemState.themeModeEnum, ThemeMode.system);

      const unknownState = SettingsState(themeMode: 'unknown');
      expect(unknownState.themeModeEnum, ThemeMode.dark);
    });
  });

  group('SettingsStore', () {
    late FakeSettingsStorageService storage;
    late SettingsStore store;

    setUp(() {
      storage = FakeSettingsStorageService();
      store = SettingsStore(storage);
    });

    test('initial state loads from storage', () async {
      storage._lunaTVUrl = 'http://test.local';
      storage._themeMode = 'light';
      storage._autoPlay = false;
      storage._defaultQuality = '1080p';
      storage._autoSelectSource = false;
      storage._blockedSources = ['source1', 'source2'];
      storage._homeBlocks = {'showRecentWatch': false};
      storage._tabOrder = ['live', 'home'];
      storage._timeshiftBufferDuration = 60;

      final newStore = SettingsStore(storage);
      await Future.delayed(Duration.zero);

      expect(newStore.state.lunaTVUrl, 'http://test.local');
      expect(newStore.state.themeMode, 'light');
      expect(newStore.state.autoPlay, false);
      expect(newStore.state.defaultQuality, '1080p');
      expect(newStore.state.autoSelectSource, false);
      expect(newStore.state.blockedSources, ['source1', 'source2']);
      expect(newStore.state.homeBlocks, {'showRecentWatch': false});
      expect(newStore.state.tabOrder, ['live', 'home']);
      expect(newStore.state.timeshiftBufferDuration, 60);
    });

    test('updateLunaTVUrl updates state and storage', () async {
      await store.updateLunaTVUrl('http://new.local');
      expect(store.state.lunaTVUrl, 'http://new.local');
      expect(storage._lunaTVUrl, 'http://new.local');
    });

    test('updateThemeMode updates state and storage', () async {
      await store.updateThemeMode('light');
      expect(store.state.themeMode, 'light');
      expect(storage._themeMode, 'light');
    });

    test('updateAutoPlay updates state and storage', () async {
      await store.updateAutoPlay(false);
      expect(store.state.autoPlay, false);
    });

    test('updateDefaultQuality updates state and storage', () async {
      await store.updateDefaultQuality('720p');
      expect(store.state.defaultQuality, '720p');
    });

    test('updateAutoSelectSource updates state and storage', () async {
      await store.updateAutoSelectSource(false);
      expect(store.state.autoSelectSource, false);
    });

    test('toggleBlockedSource adds source when not present', () async {
      await store.toggleBlockedSource('source1');
      expect(store.state.blockedSources, contains('source1'));
      expect(storage._blockedSources, contains('source1'));
    });

    test('toggleBlockedSource removes source when already present', () async {
      await store.toggleBlockedSource('source1');
      await store.toggleBlockedSource('source1');
      expect(store.state.blockedSources, isNot(contains('source1')));
    });

    test('updateHomeBlocks updates state and storage', () async {
      final blocks = {'showRecentWatch': false, 'showLive': true};
      await store.updateHomeBlocks(blocks);
      expect(store.state.homeBlocks, blocks);
    });

    test('updateTabOrder updates state and storage', () async {
      final order = ['search', 'home', 'live'];
      await store.updateTabOrder(order);
      expect(store.state.tabOrder, order);
    });

    test('timeshiftBufferDuration defaults to 30 minutes', () {
      final s = SettingsStore(FakeSettingsStorageService());
      expect(s.state.timeshiftBufferDuration, 30);
    });

    test('updateTimeshiftBufferDuration updates state and storage', () async {
      await store.updateTimeshiftBufferDuration(60);
      expect(store.state.timeshiftBufferDuration, 60);
      expect(storage._timeshiftBufferDuration, 60);
    });
  });

  group('settingsStoreProvider', () {
    test(
      'depends on settingsStorageServiceProvider which throws when not overridden',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container.read(settingsStoreProvider),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });
}
