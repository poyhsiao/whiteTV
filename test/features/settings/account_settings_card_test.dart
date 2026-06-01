import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/account_settings_card.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AccountSettingsCard', () {
    late SharedPreferences prefs;
    late SettingsStorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storageService = SettingsStorageService(prefs);
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          authStoreProvider.overrideWith((ref) {
            final store = AuthStore(storageService, MockClient());
            return store;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AccountSettingsCard()),
        ),
      );
    }

    testWidgets('shows account info section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('帳號資訊'), findsOneWidget);
    });

    testWidgets('shows login button when not logged in', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('未登入'), findsOneWidget);
    });

    testWidgets('shows username when logged in', skip: true, (tester) async {
      // Pre-populate storage before creating store
      await storageService.saveUsername('testuser');
      await storageService.saveAuthCookie('test_cookie');

      // Use ProviderContainer to properly await provider initialization
      final container = ProviderContainer(
        overrides: [
          authStoreProvider.overrideWith((ref) {
            final store = AuthStore(storageService, MockClient());
            return store;
          }),
        ],
      );

      // Add listener to wait for state changes
      var stateChanged = false;
      container.listen(authStoreProvider, (previous, next) {
        if (next.isLoggedIn == true && next.username == 'testuser') {
          stateChanged = true;
        }
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: AccountSettingsCard()),
          ),
        ),
      );

      // Wait for async _loadAuthState to complete
      await tester.pump(const Duration(seconds: 3));

      // Verify state changed or widget shows expected content
      expect(find.text('testuser'), findsOneWidget);

      container.dispose();
    });

    testWidgets('shows logout button when logged in', skip: true, (tester) async {
      // Pre-populate storage before creating store
      await storageService.saveUsername('testuser');
      await storageService.saveAuthCookie('test_cookie');

      // Use ProviderContainer to properly await provider initialization
      final container = ProviderContainer(
        overrides: [
          authStoreProvider.overrideWith((ref) {
            final store = AuthStore(storageService, MockClient());
            return store;
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: AccountSettingsCard()),
          ),
        ),
      );

      // Wait for async _loadAuthState to complete
      await tester.pump(const Duration(seconds: 3));

      // Verify logout section is visible
      expect(find.text('登出'), findsOneWidget);

      container.dispose();
    });
  });
}
