import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/features/category/category_constants.dart';
import 'package:white_tv/features/category/category_content_state.dart';

/// 分類內容 Store
class CategoryContentStore extends StateNotifier<CategoryContentState> {
  final ApiClient _apiClient;

  CategoryContentStore(this._apiClient, String categoryId)
      : super(CategoryContentState(categoryId: categoryId));

  Future<void> loadContent() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final videos = await _apiClient.getVideosByCategory(state.categoryId);
      state = state.copyWith(
        videos: videos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setSubCategory(String? subCategory) {
    state = state.copyWith(subCategory: subCategory);
  }

  void setRegion(String? region) {
    state = state.copyWith(region: region);
  }

  void setYear(String? year) {
    state = state.copyWith(year: year);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void setCategoryId(String categoryId) {
    state = CategoryContentState(categoryId: categoryId);
    loadContent();
  }

  void refresh() {
    state = state.copyWith(isLoading: true, clearError: true, videos: const []);
    loadContent();
  }
}

final categoryContentStoreProvider = StateNotifierProvider.autoDispose<
    CategoryContentStore, CategoryContentState>((ref) {
  final client = createApiClient();
  return CategoryContentStore(
    client,
    'movie',
  );
});
