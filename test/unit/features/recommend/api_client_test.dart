// test/unit/features/recommend/api_client_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

void main() {
  group('AIRecommendation API Methods', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    group('getAIRecommendations', () {
      test('returns empty list from mock', () async {
        final result = await mockClient.getAIRecommendations();
        expect(result, isEmpty);
      });

      test('returns List<AIRecommendation>', () async {
        final result = await mockClient.getAIRecommendations();
        expect(result, isA<List<AIRecommendation>>());
      });
    });

    group('getLocalRecommendations', () {
      test('returns mock recommendations with history source type', () async {
        final result = await mockClient.getLocalRecommendations();
        expect(result, isNotEmpty);
        expect(result.length, equals(2));
        expect(result.every((r) => r.sourceType == RecommendationSource.history), isTrue);
      });

      test('returns List<AIRecommendation>', () async {
        final result = await mockClient.getLocalRecommendations();
        expect(result, isA<List<AIRecommendation>>());
      });

      test('mock recommendations have required fields', () async {
        final result = await mockClient.getLocalRecommendations();
        for (final recommendation in result) {
          expect(recommendation.id, isNotEmpty);
          expect(recommendation.title, isNotEmpty);
          expect(recommendation.source, isNotEmpty);
          expect(recommendation.sourceName, isNotEmpty);
          expect(recommendation.sourceType, equals(RecommendationSource.history));
        }
      });

      test('accepts limit parameter without error', () async {
        // Note: Mock returns fixed data, limit is used by real implementation
        final result = await mockClient.getLocalRecommendations(limit: 1);
        expect(result, isA<List<AIRecommendation>>());
      });

      test('handles empty watch history', () async {
        final result = await mockClient.getLocalRecommendations(
          watchHistory: [],
          searchHistory: [],
        );
        expect(result, isNotEmpty);
      });

      test('handles null watch and search history', () async {
        final result = await mockClient.getLocalRecommendations(
          watchHistory: null,
          searchHistory: null,
        );
        expect(result, isNotEmpty);
      });
    });
  });
}
