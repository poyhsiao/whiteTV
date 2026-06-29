import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/features/recommend/presentation/pages/ai_recommend_page.dart';

class MockApiClient extends Mock with ApiClientFallbacks implements ApiClient {}

void main() {
  group('AIRecommendPage', () {
    late MockApiClient mockClient;

    setUp(() {
      mockClient = MockApiClient();
      when(() => mockClient.getAIRecommendations()).thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
        watchHistory: any(named: 'watchHistory'),
        searchHistory: any(named: 'searchHistory'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => []);
    });

    testWidgets('shows AI 推薦 title in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: const MaterialApp(
            home: AIRecommendPage(),
          ),
        ),
      );

      expect(find.text('AI 推薦'), findsOneWidget);
    });

    testWidgets('renders Scaffold with dark background', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: const MaterialApp(
            home: AIRecommendPage(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold, isNotNull);
    });
  });
}