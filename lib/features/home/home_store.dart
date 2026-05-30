import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';

/// 首頁 Store - 狀態管理

class HomeState {
  final List<Category> categories;
  final Map<String, List<Video>> videosByCategory;
  final List<PlayHistory> recentHistory;
  final List<AIRecommendation> aiRecommendations;
  final bool isLoading;
  final bool isAIRecommendationsLoading;
  final String? error;

  const HomeState({
    this.categories = const [],
    this.videosByCategory = const {},
    this.recentHistory = const [],
    this.aiRecommendations = const [],
    this.isLoading = false,
    this.isAIRecommendationsLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<Category>? categories,
    Map<String, List<Video>>? videosByCategory,
    List<PlayHistory>? recentHistory,
    List<AIRecommendation>? aiRecommendations,
    bool? isLoading,
    bool? isAIRecommendationsLoading,
    String? error,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      videosByCategory: videosByCategory ?? this.videosByCategory,
      recentHistory: recentHistory ?? this.recentHistory,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      isLoading: isLoading ?? this.isLoading,
      isAIRecommendationsLoading: isAIRecommendationsLoading ?? this.isAIRecommendationsLoading,
      error: error,
    );
  }
}

class HomeStore extends StateNotifier<HomeState> {
  final ApiClient _apiClient;
  final AIRecommendRepository _recommendRepository;
  HistoryService? _historyService;

  HomeStore(this._apiClient, [HistoryService? historyService])
      : _recommendRepository = AIRecommendRepository(_apiClient),
        _historyService = historyService,
        super(const HomeState());

  void setHistoryService(HistoryService service) {
    _historyService = service;
  }

  void clearHome() {
    state = const HomeState();
  }

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

      // Load recent history if service is available
      List<PlayHistory> recentHistory = [];
      if (_historyService != null) {
        try {
          recentHistory = await _historyService!.getHistory();
        } catch (_) {
          // Ignore history loading errors
        }
      }

      state = state.copyWith(
        categories: categories,
        videosByCategory: videosByCategory,
        recentHistory: recentHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAIRecommendations() async {
    state = state.copyWith(isAIRecommendationsLoading: true);

    try {
      final recommendations = await _recommendRepository.getRecommendations();
      state = state.copyWith(
        aiRecommendations: recommendations,
        isAIRecommendationsLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isAIRecommendationsLoading: false);
    }
  }
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) => createApiClient());
final homeStoreProvider = StateNotifierProvider<HomeStore, HomeState>((ref) {
  return HomeStore(ref.watch(apiClientProvider));
});
