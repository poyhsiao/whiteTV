import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/providers/downloads_providers.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

void main() {
  testWidgets('App smoke test - verifies app launches', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          dioProvider.overrideWithValue(dio),
          settingsStorageServiceProvider.overrideWithValue(
            SettingsStorageService(prefs),
          ),
        ],
        child: WhiteTVApp(
          router: createAppRouter(initialLocation: '/onboarding'),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App shows onboarding on first launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          dioProvider.overrideWithValue(dio),
          settingsStorageServiceProvider.overrideWithValue(
            SettingsStorageService(prefs),
          ),
        ],
        child: WhiteTVApp(
          router: createAppRouter(initialLocation: '/onboarding'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
