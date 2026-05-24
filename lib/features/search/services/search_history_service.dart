import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/api_client.dart';

class SearchHistoryService {
  static const _searchHistoryKey = 'search_history';
  static const _maxHistoryItems = 20;

  final SharedPreferences _prefs;
  final ApiClient _apiClient;

  SearchHistoryService(this._prefs, this._apiClient);

  Future<List<String>> getHistory() async {
    return List<String>.from(_prefs.getStringList(_searchHistoryKey) ?? []);
  }

  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    final history = await getHistory();

    // Remove duplicate if exists (will be moved to front)
    history.remove(query);

    // Add to front (newest first)
    history.insert(0, query);

    // Limit to max items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  Future<void> syncToCloud() async {
    final localHistory = await getHistory();
    if (localHistory.isEmpty) return;

    try {
      await _apiClient.syncSearchHistory(localHistory);
    } catch (_) {
      // Silently fail - will retry on next network event
    }
  }

  Future<List<String>> fetchFromCloud() async {
    try {
      return await _apiClient.getSearchHistory();
    } catch (_) {
      return [];
    }
  }
}