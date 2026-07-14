import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';

class FakeSettingsStorage implements SettingsStorageService {
  String? _lunaTVUrl;
  String _themeMode = 'dark';
  bool _autoPlay = true;
  String _defaultQuality = 'auto';
  bool _autoSelectSource = true;
  List<String> _blockedSources = [];
  Map<String, bool> _homeBlocks = {};
  List<String> _tabOrder = [];
  int _timeshiftBufferDuration = 30;

  @override Future<void> saveLunaTVUrl(String url) async => _lunaTVUrl = url;
  @override Future<String?> getLunaTVUrl() async => _lunaTVUrl;
  @override Future<void> saveThemeMode(String mode) async => _themeMode = mode;
  @override Future<String> getThemeMode() async => _themeMode;
  @override Future<void> saveAutoPlay(bool v) async => _autoPlay = v;
  @override Future<bool> getAutoPlay() async => _autoPlay;
  @override Future<void> saveDefaultQuality(String v) async => _defaultQuality = v;
  @override Future<String> getDefaultQuality() async => _defaultQuality;
  @override Future<void> saveAutoSelectSource(bool v) async => _autoSelectSource = v;
  @override Future<bool> getAutoSelectSource() async => _autoSelectSource;
  @override Future<void> saveBlockedSources(List<String> v) async => _blockedSources = v;
  @override Future<List<String>> getBlockedSources() async => _blockedSources;
  @override Future<void> saveHomeBlocks(Map<String, bool> v) async => _homeBlocks = v;
  @override Future<Map<String, bool>> getHomeBlocks() async => _homeBlocks;
  @override Future<void> saveTabOrder(List<String> v) async => _tabOrder = v;
  @override Future<List<String>> getTabOrder() async => _tabOrder;
  @override Future<void> saveTimeshiftBufferDuration(int v) async => _timeshiftBufferDuration = v;
  @override Future<int> getTimeshiftBufferDuration() async => _timeshiftBufferDuration;
  @override Future<String?> getPinHash() async => null;
  @override Future<void> savePinHash(String? hash) async {}
  @override Future<bool> isParentalLockEnabled() async => false;
  @override Future<void> saveParentalLockEnabled(bool v) async {}
  @override Future<String?> getUsername() async => null;
  @override Future<void> saveUsername(String? username) async {}
  @override Future<String?> getAuthCookie() async => null;
  @override Future<void> saveAuthCookie(String cookie) async {}
  @override Future<void> saveOnboardingComplete(bool complete) async {}
  @override Future<bool> getOnboardingComplete() async => false;
  @override Future<void> clearAuthCookie() async {}
}

void main() {
  group('Tab Order persistence — UI_UX.md §13.1', () {
    late SettingsStore store;
    late FakeSettingsStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSettingsStorage();
      store = SettingsStore(fakeStorage);
    });

    test('default tabOrder is empty list', () {
      expect(store.state.tabOrder, isEmpty);
    });

    test('updateTabOrder persists to storage', () async {
      const newOrder = ['live', 'search', 'home', 'favorites', 'categories', 'settings'];
      await store.updateTabOrder(newOrder);
      expect(fakeStorage._tabOrder, newOrder);
    });

    test('updateTabOrder updates state', () async {
      const newOrder = ['search', 'live'];
      await store.updateTabOrder(newOrder);
      expect(store.state.tabOrder, newOrder);
    });
  });
}
