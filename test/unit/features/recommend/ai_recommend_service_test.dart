import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/services/ai_recommend_service.dart';

void main() {
  late AIRecommendService service;

  setUp(() {
    service = AIRecommendService();
  });

  group('AIRecommendService', () {
    test('generateLocalRecommendations returns recommendations based on history', () {
      // Arrange
      final watchHistory = ['科幻', '周星馳'];
      final searchHistory = ['星際穿越', '盜夢空間'];

      // Act
      final result = service.generateLocalRecommendations(
        watchHistory: watchHistory,
        searchHistory: searchHistory,
        limit: 10,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.sourceType, equals(RecommendationSource.history));
    });

    test('generatePopularRecommendations returns popular content', () {
      // Act
      final result = service.generatePopularRecommendations(limit: 10);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.sourceType, equals(RecommendationSource.popular));
    });

    test('extractWatchPreferences extracts types and genres from history', () {
      // Arrange
      final watchRecords = [
        {'type': 'movie', 'title': '星際穿越'},
        {'type': 'movie', 'title': '盜夢空間'},
        {'type': 'drama', 'title': '魷魚遊戲'},
      ];

      // Act
      final preferences = service.extractWatchPreferences(watchRecords);

      // Assert
      expect(preferences['types'], contains('movie'));
      expect(preferences['types'], contains('drama'));
      expect(preferences['titles'], contains('星際穿越'));
    });
  });
}