import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/features/settings/services/settings_storage_fallbacks.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class FakeSettingsStorageService with SettingsStorageServiceFallbacks implements SettingsStorageService {
  String? _authCookie;
  String? _username;

  @override
  Future<void> saveAuthCookie(String cookie) async => _authCookie = cookie;

  @override
  Future<String?> getAuthCookie() async => _authCookie;

  @override
  Future<void> clearAuthCookie() async => _authCookie = null;

  @override
  Future<void> saveUsername(String? username) async => _username = username;

  @override
  Future<String?> getUsername() async => _username;

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
}

class FakeApiClient with ApiClientFallbacks implements ApiClient {
  Map<String, String>? _loginResult;
  Exception? _loginException;

  void setLoginResult(Map<String, String>? result) => _loginResult = result;
  void setLoginException(Exception e) => _loginException = e;

  @override
  Future<Map<String, String>?> login(String username, String password) async {
    if (_loginException != null) throw _loginException!;
    return _loginResult;
  }

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async => [];

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async =>
      throw UnimplementedError();

  @override
  Future<List<VideoSource>> getSources(String videoId) async => [];

  @override
  Future<int> testSourceLatency(String sourceUrl) async => 0;

  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async =>
      [];

  @override
  Future<Map<String, dynamic>> getUserStats() async => {};

  @override
  Future<void> syncSearchHistory(List<String> history) async {}

  @override
  Future<List<String>> getSearchHistory() async => [];

  @override
  Future<bool> savePlayHistory(PlayHistory record) async => true;

  @override
  Future<List<IptvChannel>> getIptvChannels() async => [];

  @override
  Future<String?> getIptvM3U() async => null;

  @override
  Future<Map<String, dynamic>> getIptvEpg() async => {};

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async => [];

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async => [];
}

void main() {
  group('AuthState', () {
    test('has correct default values', () {
      const state = AuthState();
      expect(state.isLoggedIn, false);
      expect(state.username, isNull);
      expect(state.error, isNull);
    });

    test('copyWith creates new instance with updated values', () {
      const state = AuthState();
      final updated = state.copyWith(isLoggedIn: true, username: 'testuser');
      expect(updated.isLoggedIn, true);
      expect(updated.username, 'testuser');
      expect(updated.error, isNull);
    });

    test('copyWith preserves existing values when not overridden', () {
      const state = AuthState(
        isLoggedIn: true,
        username: 'testuser',
        error: 'some error',
      );
      final updated = state.copyWith(isLoggedIn: false);
      expect(updated.isLoggedIn, false);
      expect(updated.username, 'testuser');
      expect(updated.error, 'some error');
    });

    test('copyWith with only error update works correctly', () {
      const state = AuthState();
      final updated = state.copyWith(error: 'login failed');
      expect(updated.isLoggedIn, false);
      expect(updated.username, isNull);
      expect(updated.error, 'login failed');
    });
  });

  group('AuthStore', () {
    late FakeSettingsStorageService storage;
    late FakeApiClient apiClient;
    late ProviderContainer container;
    late AuthStore store;

    setUp(() {
      storage = FakeSettingsStorageService();
      apiClient = FakeApiClient();
      container = ProviderContainer(
        overrides: [
          settingsStorageServiceProvider.overrideWithValue(storage),
          lunaClientProvider.overrideWithValue(apiClient),
        ],
      );
      store = AuthStore(storage, apiClient);
    });

    tearDown(() => container.dispose());

    test('initial state is not logged in', () {
      expect(store.state.isLoggedIn, false);
      expect(store.state.username, isNull);
      expect(store.state.error, isNull);
    });

    test('login success updates state to logged in', () async {
      apiClient.setLoginResult({
        'cookie': 'test-cookie-123',
        'username': 'testuser',
      });

      final result = await store.login('testuser', 'password123');

      expect(result, true);
      expect(store.state.isLoggedIn, true);
      expect(store.state.username, 'testuser');
      expect(store.state.error, isNull);
    });

    test('login success saves auth cookie and username to storage', () async {
      apiClient.setLoginResult({
        'cookie': 'test-cookie-123',
        'username': 'testuser',
      });

      await store.login('testuser', 'password123');

      expect(storage._authCookie, 'test-cookie-123');
      expect(storage._username, 'testuser');
    });

    test('login failure sets error state', () async {
      apiClient.setLoginResult(null);

      final result = await store.login('testuser', 'wrongpassword');

      expect(result, false);
      expect(store.state.isLoggedIn, false);
      expect(store.state.error, '登入失敗');
    });

    test('login exception sets error state', () async {
      apiClient.setLoginException(Exception('Network error'));

      final result = await store.login('testuser', 'password');

      expect(result, false);
      expect(store.state.isLoggedIn, false);
      expect(store.state.error, contains('Network error'));
    });

    test('logout clears state and storage', () async {
      apiClient.setLoginResult({
        'cookie': 'test-cookie',
        'username': 'testuser',
      });
      await store.login('testuser', 'password');
      expect(store.state.isLoggedIn, true);

      await store.logout();

      expect(store.state.isLoggedIn, false);
      expect(store.state.username, isNull);
      expect(storage._authCookie, isNull);
      expect(storage._username, isNull);
    });

    test('loading saved auth state on initialization', () async {
      storage._authCookie = 'saved-cookie';
      storage._username = 'saved-user';

      final newStore = AuthStore(storage, apiClient);
      await Future.delayed(Duration.zero);

      expect(newStore.state.isLoggedIn, true);
      expect(newStore.state.username, 'saved-user');
    });
  });

  group('authStoreProvider', () {
    test('can be accessed via ProviderContainer', () async {
      final storage = FakeSettingsStorageService();
      final apiClient = FakeApiClient();

      final container = ProviderContainer(
        overrides: [
          settingsStorageServiceProvider.overrideWithValue(storage),
          lunaClientProvider.overrideWithValue(apiClient),
        ],
      );

      final authStore = container.read(authStoreProvider.notifier);
      expect(authStore.state.isLoggedIn, false);

      container.dispose();
    });
  });
}
