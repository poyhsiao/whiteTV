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

    Widget buildTestWidget({AuthState? initialAuthState}) {
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
      await tester.pumpAndSettle();

      expect(find.text('帳號資訊'), findsOneWidget);
    });

    testWidgets('shows login button when not logged in', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('未登入'), findsOneWidget);
    });

    testWidgets('shows username when logged in', (tester) async {
      await storageService.saveUsername('testuser');
      await storageService.saveAuthCookie('test_cookie');

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('testuser'), findsOneWidget);
    });

    testWidgets('shows logout button when logged in', (tester) async {
      await storageService.saveUsername('testuser');
      await storageService.saveAuthCookie('test_cookie');

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('登出'), findsOneWidget);
    });
  });
}
