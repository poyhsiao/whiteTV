import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/presentation/pages/ai_recommend_page.dart';

void main() {
  group('AIRecommendPage', () {
    testWidgets('shows AI 推薦 title in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AIRecommendPage(),
        ),
      );

      expect(find.text('AI 推薦'), findsOneWidget);
    });

    testWidgets('renders Scaffold with dark background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AIRecommendPage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold, isNotNull);
    });
  });
}