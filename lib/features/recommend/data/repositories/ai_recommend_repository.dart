import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class AIRecommendRepository {
  final ApiClient _apiClient;

  AIRecommendRepository(this._apiClient);

  /// Get recommendations using dual-track strategy
  /// - First tries AI API
  /// - Falls back to local recommendations if AI returns empty
  Future<List<AIRecommendation>> getRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    // Try AI API first
    final aiRecommendations = await _apiClient.getAIRecommendations();

    if (aiRecommendations.isNotEmpty) {
      return aiRecommendations;
    }

    // Fallback: use local recommendations
    return _apiClient.getLocalRecommendations(
      watchHistory: watchHistory,
      searchHistory: searchHistory,
      limit: limit,
    );
  }
}