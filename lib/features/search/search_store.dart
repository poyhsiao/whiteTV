import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';

/// SearchStore - 搜尋功能狀態管理
class SearchStore extends StateNotifier<SearchState> {
  final ApiClient _apiClient;
  final SearchHistoryService? _historyService;
  bool _isSearching = false;

  SearchStore(this._apiClient, [this._historyService]) : super(const SearchState());

  /// 載入搜尋歷史
  Future<void> loadHistory() async {
    if (_historyService == null) return;

    final localHistory = await _historyService.getHistory();
    final cloudHistory = await _historyService.fetchFromCloud();

    // Merge: local priority, cloud as backup
    final merged = <String>{...localHistory, ...cloudHistory}.toList();
    state = state.copyWith(searchHistory: merged.take(20).toList());
  }

  /// 保存搜尋記錄
  Future<void> saveToHistory(String query) async {
    if (_historyService == null) return;
    await _historyService.saveSearch(query);
    await loadHistory();
  }

  /// 搜尋影片
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: [], isLoading: false);
      return;
    }

    // Prevent concurrent searches
    if (_isSearching) return;
    _isSearching = true;

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final results = await _apiClient.search(
        query,
        category: state.activeCategory,
      );
      if (mounted) {
        state = state.copyWith(results: results, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    } finally {
      _isSearching = false;
    }
  }

  /// 設定分類並重新搜尋
  void setCategory(SearchCategory category) {
    state = state.copyWith(activeCategory: category);
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  /// 切換鍵盤模式
  void toggleKeyboardMode() {
    state = state.copyWith(isKeyboardMode: !state.isKeyboardMode);
  }

  /// 清除搜尋
  void clearSearch() {
    state = state.copyWith(
      query: '',
      results: [],
      searchHistory: [...state.searchHistory, if (state.query.isNotEmpty) state.query],
      isLoading: false,
      error: null,
      clearError: true,
    );
  }
}

/// Provider
final searchStoreProvider = StateNotifierProvider<SearchStore, SearchState>((ref) {
  throw UnimplementedError('searchStoreProvider must be overridden');
});