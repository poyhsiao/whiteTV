import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class AIRecommendService {
  /// Generate local recommendations based on user history
  List<AIRecommendation> generateLocalRecommendations({
    required List<String> watchHistory,
    required List<String> searchHistory,
    int limit = 20,
  }) {
    // If search history exists, use it
    if (searchHistory.isNotEmpty) {
      return _generateFromSearchHistory(searchHistory, limit);
    }

    // If watch history exists, use it
    if (watchHistory.isNotEmpty) {
      return _generateFromWatchHistory(watchHistory, limit);
    }

    // Fallback to popular recommendations
    return generatePopularRecommendations(limit: limit);
  }

  List<AIRecommendation> _generateFromSearchHistory(
    List<String> history,
    int limit,
  ) {
    return history.take(limit).map((keyword) {
      return AIRecommendation(
        id: 'search-$keyword',
        title: '關於 $keyword 的推薦',
        source: 'local',
        sourceName: '本地推薦',
        reason: '根據您的搜尋記錄「$keyword」',
        sourceType: RecommendationSource.history,
      );
    }).toList();
  }

  List<AIRecommendation> _generateFromWatchHistory(
    List<String> history,
    int limit,
  ) {
    return history.take(limit).map((type) {
      return AIRecommendation(
        id: 'watch-$type',
        title: '$type 類型推薦',
        source: 'local',
        sourceName: '本地推薦',
        reason: '根據您觀看的 $type 內容',
        sourceType: RecommendationSource.history,
      );
    }).toList();
  }

  /// Generate popular recommendations
  List<AIRecommendation> generatePopularRecommendations({int limit = 20}) {
    return List.generate(
      limit,
      (index) => AIRecommendation(
        id: 'popular-$index',
        title: '熱門推薦 ${index + 1}',
        source: 'popular',
        sourceName: '熱門推薦',
        reason: '當前熱門內容',
        sourceType: RecommendationSource.popular,
      ),
    );
  }

  /// Extract user preferences from watch records
  Map<String, List<String>> extractWatchPreferences(List<Map<String, dynamic>> records) {
    final types = <String>{};
    final titles = <String>[];

    for (final record in records) {
      if (record['type'] != null) {
        types.add(record['type'] as String);
      }
      if (record['title'] != null) {
        titles.add(record['title'] as String);
      }
    }

    return {
      'types': types.toList(),
      'titles': titles,
    };
  }
}