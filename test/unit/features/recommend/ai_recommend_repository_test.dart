import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';

class MockApiClient extends Mock with ApiClientFallbacks implements ApiClient {}

void main() {
  late AIRecommendRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = AIRecommendRepository(mockApiClient);
  });

  group('AIRecommendRepository', () {
    group('getRecommendations', () {
      test('returns AI recommendations when AI API returns results', () async {
        // Arrange
        final aiRecommendations = <AIRecommendation>[
          const AIRecommendation(
            id: '1',
            title: 'AI Rec 1',
            source: 'lunatv',
            sourceName: 'LunaTV',
            sourceType: RecommendationSource.ai,
          ),
          const AIRecommendation(
            id: '2',
            title: 'AI Rec 2',
            source: 'lunatv',
            sourceName: 'LunaTV',
            sourceType: RecommendationSource.ai,
          ),
        ];
        when(() => mockApiClient.getAIRecommendations())
            .thenAnswer((_) async => aiRecommendations);

        // Act
        final result = await repository.getRecommendations();

        // Assert
        expect(result, equals(aiRecommendations));
        verify(() => mockApiClient.getAIRecommendations()).called(1);
        verifyNever(() => mockApiClient.getLocalRecommendations(
            watchHistory: any(named: 'watchHistory'),
            searchHistory: any(named: 'searchHistory'),
            limit: any(named: 'limit')));
      });

      test('falls back to local recommendations when AI returns empty',
          () async {
        // Arrange
        final localRecommendations = <AIRecommendation>[
          const AIRecommendation(
            id: '3',
            title: 'Local Rec 1',
            source: 'local',
            sourceName: 'Local',
            sourceType: RecommendationSource.history,
          ),
        ];
        when(() => mockApiClient.getAIRecommendations())
            .thenAnswer((_) async => []);
        when(() => mockApiClient.getLocalRecommendations(
                watchHistory: any(named: 'watchHistory'),
                searchHistory: any(named: 'searchHistory'),
                limit: any(named: 'limit')))
            .thenAnswer((_) async => localRecommendations);

        // Act
        final result = await repository.getRecommendations(
          watchHistory: ['show1'],
          searchHistory: ['drama'],
          limit: 10,
        );

        // Assert
        expect(result, equals(localRecommendations));
        verify(() => mockApiClient.getAIRecommendations()).called(1);
        verify(() => mockApiClient.getLocalRecommendations(
              watchHistory: ['show1'],
              searchHistory: ['drama'],
              limit: 10,
            )).called(1);
      });

      test('returns empty list when both AI and local return empty', () async {
        // Arrange
        when(() => mockApiClient.getAIRecommendations())
            .thenAnswer((_) async => <AIRecommendation>[]);
        when(() => mockApiClient.getLocalRecommendations(
                watchHistory: any(named: 'watchHistory'),
                searchHistory: any(named: 'searchHistory'),
                limit: any(named: 'limit')))
            .thenAnswer((_) async => <AIRecommendation>[]);

        // Act
        final result = await repository.getRecommendations();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}