import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Live TV Flow E2E', () {
    testWidgets('User can navigate to live TV', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/live'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - App renders
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
