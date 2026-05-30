import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_card.dart';

void main() {
  group('RecommendationCard', () {
    testWidgets('displays AI tag for AI recommendations', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'lovedan',
        sourceName: '量子資源',
        sourceType: RecommendationSource.ai,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('🤖 AI'), findsOneWidget);
    });

    testWidgets('displays preference tag for history recommendations', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'lovedan',
        sourceName: '量子資源',
        sourceType: RecommendationSource.history,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('📺 偏好'), findsOneWidget);
    });

    testWidgets('displays popular tag for popular recommendations', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'popular',
        sourceName: '熱門推薦',
        sourceType: RecommendationSource.popular,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('🔥 熱門'), findsOneWidget);
    });

    testWidgets('shows title correctly', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'lovedan',
        sourceName: '量子資源',
        sourceType: RecommendationSource.ai,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('星際穿越'), findsOneWidget);
    });
  });
}
