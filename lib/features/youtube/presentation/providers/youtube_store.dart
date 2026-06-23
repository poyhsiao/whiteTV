import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';

/// YouTube Store 狀態管理

enum YoutubeStatus { initial, loading, loaded, error }

class YoutubeState {
  final YoutubeStatus status;
  final List<YoutubeVideo> recommendVideos;
  final List<YoutubeCategory> categories;
  final Map<String, List<YoutubeVideo>> videosByCategory;
  final String? selectedCategoryId;
  final String? error;

  const YoutubeState({
    this.status = YoutubeStatus.initial,
    this.recommendVideos = const [],
    this.categories = const [],
    this.videosByCategory = const {},
    this.selectedCategoryId,
    this.error,
  });

  YoutubeState copyWith({
    YoutubeStatus? status,
    List<YoutubeVideo>? recommendVideos,
    List<YoutubeCategory>? categories,
    Map<String, List<YoutubeVideo>>? videosByCategory,
    String? selectedCategoryId,
    String? error,
  }) {
    return YoutubeState(
      status: status ?? this.status,
      recommendVideos: recommendVideos ?? this.recommendVideos,
      categories: categories ?? this.categories,
      videosByCategory: videosByCategory ?? this.videosByCategory,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      error: error,
    );
  }
}

class YoutubeStore extends StateNotifier<YoutubeState> {
  final ApiClient _apiClient;

  YoutubeStore(this._apiClient) : super(const YoutubeState());

  void clear() {
    state = const YoutubeState();
  }

  Future<void> loadRecommend() async {
    state = state.copyWith(status: YoutubeStatus.loading, error: null);

    try {
      final videos = await _apiClient.getYoutubeRecommend();
      state = state.copyWith(
        status: YoutubeStatus.loaded,
        recommendVideos: videos,
      );
    } catch (e) {
      state = state.copyWith(
        status: YoutubeStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(status: YoutubeStatus.loading, error: null);

    try {
      final categories = await _apiClient.getYoutubeCategories();
      state = state.copyWith(
        status: YoutubeStatus.loaded,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        status: YoutubeStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> selectCategory(String categoryId) async {
    state = state.copyWith(
      status: YoutubeStatus.loading,
      selectedCategoryId: categoryId,
      error: null,
    );

    try {
      final videos = await _apiClient.getYoutubeList(categoryId);
      final updatedMap = Map<String, List<YoutubeVideo>>.from(state.videosByCategory);
      updatedMap[categoryId] = videos;
      state = state.copyWith(
        status: YoutubeStatus.loaded,
        videosByCategory: updatedMap,
      );
    } catch (e) {
      state = state.copyWith(
        status: YoutubeStatus.error,
        error: e.toString(),
      );
    }
  }
}

// Provider
final youtubeStoreProvider = StateNotifierProvider<YoutubeStore, YoutubeState>((ref) {
  throw UnimplementedError('youtubeStoreProvider must be overridden in ProviderScope');
});
