import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

/// Sets up common plugin mocks for E2E widget tests.
/// Call this BEFORE pumpWidget in each test.
void setupE2EPluginMocks() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory' ||
          methodCall.method == 'getApplicationSupportDirectory' ||
          methodCall.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.createTempSync('e2e_test_').path;
      }
      return null;
    },
  );
}

/// FakeSettingsStorageService for E2E tests.
class FakeSettingsStorageService implements SettingsStorageService {
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
  Future<bool> getAutoSelectSource() async => false;
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

/// FakeApiClient for E2E tests with configurable login.
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
  Future<VideoDetail> getVideoDetail(String videoId) async => throw UnimplementedError();
  @override
  Future<List<VideoSource>> getSources(String videoId) async => [];
  @override
  Future<int> testSourceLatency(String sourceUrl) async => 0;
  @override
  Future<List<Video>> search(String query, {SearchCategory? category}) async => [];
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

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async => [];

  @override
  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async => [];

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async => [];
}
