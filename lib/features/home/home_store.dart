import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/core/api/models.dart';

/// 首頁 Store - 狀態管理

class HomeState {
  final List<Category> categories;
  final Map<String, List<Video>> videosByCategory;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.categories = const [],
    this.videosByCategory = const {},
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<Category>? categories,
    Map<String, List<Video>>? videosByCategory,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      videosByCategory: videosByCategory ?? this.videosByCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeStore extends StateNotifier<HomeState> {
  final ApiClient _apiClient;

  HomeStore(this._apiClient) : super(const HomeState());

  Future<void> loadHome() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _apiClient.getCategories();

      final videosByCategory = <String, List<Video>>{};
      await Future.wait(
        categories.map((cat) async {
          final videos = await _apiClient.getVideosByCategory(cat.id);
          videosByCategory[cat.id] = videos;
        }),
      );

      state = state.copyWith(
        categories: categories,
        videosByCategory: videosByCategory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) => createApiClient());
final homeStoreProvider =
    StateNotifierProvider<HomeStore, HomeState>((ref) {
  return HomeStore(ref.watch(apiClientProvider));
});