import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/search/search_state.dart';

/// SearchStore - 搜尋功能狀態管理
class SearchStore extends StateNotifier<SearchState> {
  final ApiClient _apiClient;

  SearchStore(this._apiClient) : super(const SearchState());

  /// 搜尋影片
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final results = await _apiClient.search(
        query,
        category: state.activeCategory,
      );
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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