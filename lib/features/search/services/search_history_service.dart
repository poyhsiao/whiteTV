import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _searchHistoryKey = 'search_history';
  static const _maxHistoryItems = 20;

  final SharedPreferences _prefs;

  SearchHistoryService(this._prefs);

  Future<List<String>> getHistory() async {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> saveSearch(String query) async {
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
}