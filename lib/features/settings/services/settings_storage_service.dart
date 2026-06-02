import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorageService {
  static const _lunaTVUrlKey = 'luna_tv_url';
  static const _themeModeKey = 'theme_mode';
  static const _autoPlayKey = 'auto_play';
  static const _defaultQualityKey = 'default_quality';
  static const _autoSelectSourceKey = 'auto_select_source';
  static const _blockedSourcesKey = 'blocked_sources';
  static const _tabOrderKey = 'tab_order';
  static const _usernameKey = 'username';
  static const _authCookieKey = 'auth_cookie';
  static const _onboardingCompleteKey = 'onboarding_complete';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  SettingsStorageService(this._prefs, [FlutterSecureStorage? secureStorage])
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // LunaTV URL
  Future<void> saveLunaTVUrl(String url) async {
    await _prefs.setString(_lunaTVUrlKey, url);
  }

  Future<String?> getLunaTVUrl() async {
    return _prefs.getString(_lunaTVUrlKey);
  }

  // Theme Mode
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  Future<String> getThemeMode() async {
    return _prefs.getString(_themeModeKey) ?? 'dark';
  }

  // Auto Play
  Future<void> saveAutoPlay(bool enabled) async {
    await _prefs.setBool(_autoPlayKey, enabled);
  }

  Future<bool> getAutoPlay() async {
    return _prefs.getBool(_autoPlayKey) ?? true;
  }

  // Default Quality
  Future<void> saveDefaultQuality(String quality) async {
    await _prefs.setString(_defaultQualityKey, quality);
  }

  Future<String> getDefaultQuality() async {
    return _prefs.getString(_defaultQualityKey) ?? 'auto';
  }

  // Auto Select Source
  Future<void> saveAutoSelectSource(bool enabled) async {
    await _prefs.setBool(_autoSelectSourceKey, enabled);
  }

  Future<bool> getAutoSelectSource() async {
    return _prefs.getBool(_autoSelectSourceKey) ?? true;
  }

  // Blocked Sources
  Future<void> saveBlockedSources(List<String> sources) async {
    await _prefs.setStringList(_blockedSourcesKey, sources);
  }

  Future<List<String>> getBlockedSources() async {
    return _prefs.getStringList(_blockedSourcesKey) ?? [];
  }

  // Home Blocks Visibility
  Future<void> saveHomeBlocks(Map<String, bool> blocks) async {
    for (final entry in blocks.entries) {
      await _prefs.setBool('home_blocks_${entry.key}', entry.value);
    }
  }

  Future<Map<String, bool>> getHomeBlocks() async {
    return {
      'showRecentWatch': _prefs.getBool('home_blocks_showRecentWatch') ?? true,
      'showLive': _prefs.getBool('home_blocks_showLive') ?? true,
      'showCategories': _prefs.getBool('home_blocks_showCategories') ?? true,
      'showAIRecommend': _prefs.getBool('home_blocks_showAIRecommend') ?? true,
      'showHotMovies': _prefs.getBool('home_blocks_showHotMovies') ?? true,
    };
  }

  // Tab Order
  Future<void> saveTabOrder(List<String> order) async {
    await _prefs.setStringList(_tabOrderKey, order);
  }

  Future<List<String>> getTabOrder() async {
    return _prefs.getStringList(_tabOrderKey) ??
        ['home', 'categories', 'live', 'search', 'favorites', 'settings'];
  }

  // Username
  Future<void> saveUsername(String? username) async {
    if (username != null) {
      await _prefs.setString(_usernameKey, username);
    } else {
      await _prefs.remove(_usernameKey);
    }
  }

  Future<String?> getUsername() async {
    return _prefs.getString(_usernameKey);
  }

  // Auth Cookie (secure storage)
  Future<void> saveAuthCookie(String cookie) async {
    await _secureStorage.write(key: _authCookieKey, value: cookie);
  }

  Future<String?> getAuthCookie() async {
    return await _secureStorage.read(key: _authCookieKey);
  }

  Future<void> clearAuthCookie() async {
    await _secureStorage.delete(key: _authCookieKey);
  }

  // Onboarding Complete
  Future<void> saveOnboardingComplete(bool complete) async {
    await _prefs.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> getOnboardingComplete() async {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }
}
