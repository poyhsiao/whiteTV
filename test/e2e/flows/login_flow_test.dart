import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import '../e2e_test_helpers.dart';
import '../pages/login_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow E2E', () {
    testWidgets('User can login and see home', skip: true,
        // ponytail: skip - requires device (sqflite via cached_network_image)
        (WidgetTester tester) async {
      setupE2EPluginMocks();
      final fakeStorage = FakeSettingsStorageService();
      final fakeApiClient = FakeApiClient()
        ..setLoginResult({'cookie': 'test-cookie', 'username': 'testuser'});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(fakeStorage),
            lunaClientProvider.overrideWithValue(fakeApiClient),
          ],
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/login'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final loginPage = LoginPage(tester);
      await loginPage.login('testuser', 'testpass');

      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
