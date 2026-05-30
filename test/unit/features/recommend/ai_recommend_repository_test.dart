import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockClient;
  late AIRecommendRepository repository;

  setUp(() {
    mockClient = MockApiClient();
    repository = AIRecommendRepository(mockClient);
  });

  group('AIRecommendRepository', () {
    test('getRecommendations returns AI recommendations when available', () async {
      // Arrange
      final aiRecommendations = [
        const AIRecommendation(
          id: '12345',
          title: '星際穿越',
          source: 'lovedan',
          sourceName: '量子資源',
          sourceType: RecommendationSource.ai,
        ),
      ];
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => aiRecommendations);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result.first.sourceType, equals(RecommendationSource.ai));
      expect(result.length, equals(1));
      verify(() => mockClient.getAIRecommendations()).called(1);
      verifyNever(() => mockClient.getLocalRecommendations());
    });

    test('getRecommendations falls back to local when AI returns empty', () async {
      // Arrange
      final localRecommendations = [
        const AIRecommendation(
          id: 'local-1',
          title: '盜夢空間',
          source: 'mtzy.me',
          sourceName: '茅台资源',
          sourceType: RecommendationSource.history,
        ),
      ];
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
        watchHistory: any(named: 'watchHistory'),
        searchHistory: any(named: 'searchHistory'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => localRecommendations);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result.first.sourceType, equals(RecommendationSource.history));
      expect(result.length, equals(1));
      verify(() => mockClient.getAIRecommendations()).called(1);
      verify(() => mockClient.getLocalRecommendations(
        watchHistory: any(named: 'watchHistory'),
        searchHistory: any(named: 'searchHistory'),
        limit: any(named: 'limit'),
      )).called(1);
    });

    test('getRecommendations returns empty list when both fail', () async {
      // Arrange
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
        watchHistory: any(named: 'watchHistory'),
        searchHistory: any(named: 'searchHistory'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result, isEmpty);
    });
  });
}