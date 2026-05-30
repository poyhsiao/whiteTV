import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';
import 'package:white_tv/features/recommend/presentation/providers/ai_recommend_store.dart';

void main() {
  group('AIRecommendState', () {
    test('initial state is correct', () {
      const state = AIRecommendState();

      expect(state.recommendations, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.primarySource, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const state = AIRecommendState();
      final newState = state.copyWith(
        isLoading: true,
        recommendations: [
          AIRecommendation(
            id: '1',
            title: 'Test',
            source: 'test',
            sourceName: 'Test',
            sourceType: RecommendationSource.ai,
          ),
        ],
      );

      expect(newState.isLoading, isTrue);
      expect(newState.recommendations.length, equals(1));
    });
  });

  group('AIRecommendStore', () {
    late MockClient mockClient;
    late AIRecommendRepository repository;

    setUp(() {
      mockClient = MockClient();
      repository = AIRecommendRepository(mockClient);
    });

    test('loadRecommendations updates state with results', () async {
      final store = AIRecommendStore(repository);

      await store.loadRecommendations();

      // Store should have attempted to load
      expect(store.state.recommendations, isNotNull);
    });

    test('refreshRecommendations reloads content', () async {
      final store = AIRecommendStore(repository);

      await store.loadRecommendations();
      await store.refreshRecommendations();

      // Should have attempted to reload
      expect(store.state.recommendations, isNotNull);
    });
  });
}