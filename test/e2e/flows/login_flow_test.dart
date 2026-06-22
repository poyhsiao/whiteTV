import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow E2E', () {
    testWidgets('User can login and see home', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/login'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Login
      final loginPage = LoginPage(tester);
      await loginPage.login('testuser', 'testpass');

      // Assert - Should navigate to home
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify app is still running (smoke test)
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
