import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('step 1 shows welcome screen with start button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('歡迎使用 whiteTV'), findsOneWidget);
      expect(find.text('開始設定'), findsOneWidget);
    });

    testWidgets('tapping start shows step 2 with URL input', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('開始設定'));
      await tester.pump();

      expect(find.text('請輸入 LunaTV 伺服器地址'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
