import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class AIRecommendRepository {
  final ApiClient _apiClient;

  AIRecommendRepository(this._apiClient);

  /// 獲取推薦（雙軌策略）
  Future<List<AIRecommendation>> getRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    // 先嘗試 AI API
    final aiRecommendations = await _apiClient.getAIRecommendations();

    if (aiRecommendations.isNotEmpty) {
      return aiRecommendations;
    }

    // Fallback: 使用本地推薦
    return _apiClient.getLocalRecommendations(
      watchHistory: watchHistory,
      searchHistory: searchHistory,
      limit: limit,
    );
  }

  /// 直接獲取 AI 推薦
  Future<List<AIRecommendation>> getAIRecommendations() {
    return _apiClient.getAIRecommendations();
  }

  /// 直接獲取本地推薦
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) {
    return _apiClient.getLocalRecommendations(
      watchHistory: watchHistory,
      searchHistory: searchHistory,
      limit: limit,
    );
  }
}