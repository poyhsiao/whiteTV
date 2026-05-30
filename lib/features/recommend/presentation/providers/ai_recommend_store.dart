import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';

class AIRecommendState {
  final List<AIRecommendation> recommendations;
  final bool isLoading;
  final String? error;
  final RecommendationSource? primarySource;
  final DateTime? lastUpdated;

  const AIRecommendState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
    this.primarySource,
    this.lastUpdated,
  });

  AIRecommendState copyWith({
    List<AIRecommendation>? recommendations,
    bool? isLoading,
    String? error,
    RecommendationSource? primarySource,
    DateTime? lastUpdated,
  }) {
    return AIRecommendState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      primarySource: primarySource ?? this.primarySource,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AIRecommendStore extends StateNotifier<AIRecommendState> {
  final AIRecommendRepository _repository;

  AIRecommendStore(this._repository) : super(const AIRecommendState());

  Future<void> loadRecommendations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final recommendations = await _repository.getRecommendations();

      // Determine primary source
      RecommendationSource? primarySource;
      if (recommendations.isNotEmpty) {
        primarySource = recommendations.first.sourceType;
      }

      state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
        primarySource: primarySource,
        lastUpdated: DateTime.now(),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshRecommendations() async {
    await loadRecommendations();
  }
}

// Provider
final aiRecommendStoreProvider =
    StateNotifierProvider<AIRecommendStore, AIRecommendState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AIRecommendStore(AIRecommendRepository(apiClient));
});
