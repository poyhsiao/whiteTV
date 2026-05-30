// test/unit/features/recommend/models/ai_recommendation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

void main() {
  group('AIRecommendation', () {
    test('fromJson parses AI response correctly', () {
      final json = {
        'id': '12345',
        'title': '星際穿越',
        'poster': 'https://example.com/poster.jpg',
        'year': '2014',
        'source': 'lovedan',
        'source_name': '量子資源',
        'type': 'movie',
        'reason': '根據您的觀看偏好推薦',
      };

      final recommendation = AIRecommendation.fromJson(json);

      expect(recommendation.id, equals('12345'));
      expect(recommendation.title, equals('星際穿越'));
      expect(recommendation.posterUrl, equals('https://example.com/poster.jpg'));
      expect(recommendation.year, equals('2014'));
      expect(recommendation.source, equals('lovedan'));
      expect(recommendation.sourceName, equals('量子資源'));
      expect(recommendation.type, equals('movie'));
      expect(recommendation.reason, equals('根據您的觀看偏好推薦'));
      expect(recommendation.sourceType, equals(RecommendationSource.ai));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': '12345',
        'title': '星際穿越',
        'poster': 'https://example.com/poster.jpg',
        'source': 'lovedan',
        'source_name': '量子資源',
      };

      final recommendation = AIRecommendation.fromJson(json);

      expect(recommendation.year, isNull);
      expect(recommendation.type, isNull);
      expect(recommendation.reason, isNull);
    });

    test('RecommendationSource enum has correct values', () {
      expect(RecommendationSource.values.length, equals(3));
      expect(RecommendationSource.ai.name, equals('ai'));
      expect(RecommendationSource.history.name, equals('history'));
      expect(RecommendationSource.popular.name, equals('popular'));
    });

    test('toJson produces correct output', () {
      const recommendation = AIRecommendation(
        id: '12345',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        source: 'lovedan',
        sourceName: '量子資源',
        reason: '測試理由',
        sourceType: RecommendationSource.ai,
        description: '測試描述',
        year: '2014',
        type: 'movie',
        doubanId: 'tt0816692',
        episodeTotal: 1,
      );

      final json = recommendation.toJson();

      expect(json['id'], equals('12345'));
      expect(json['title'], equals('星際穿越'));
      expect(json['poster_url'], equals('https://example.com/poster.jpg'));
      expect(json['source'], equals('lovedan'));
      expect(json['source_name'], equals('量子資源'));
      expect(json['reason'], equals('測試理由'));
      expect(json['source_type'], equals('ai'));
      expect(json['description'], equals('測試描述'));
      expect(json['year'], equals('2014'));
      expect(json['type'], equals('movie'));
      expect(json['douban_id'], equals('tt0816692'));
      expect(json['total_episodes'], equals(1));
    });
  });
}