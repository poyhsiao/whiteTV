import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/general_settings_card.dart';
import 'package:white_tv/features/settings/widgets/tab_order_editor.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GeneralSettingsCard', () {
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
          settingsStorageServiceProvider.overrideWithValue(storageService),
        ],
        child: const MaterialApp(
          home: Scaffold(body: GeneralSettingsCard()),
        ),
      );
    }

    testWidgets('renders LunaTV URL setting', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('LunaTV URL'), findsOneWidget);
 });

    testWidgets('renders theme mode selector', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('主題模式'), findsOneWidget);
    });

    testWidgets('renders tab order editor', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TabOrderEditor), findsOneWidget);
    });

    testWidgets('shows current LunaTV URL value', (tester) async {
      await storageService.saveLunaTVUrl('https://test.example.com');
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('https://test.example.com'), findsOneWidget);
    });

    testWidgets('shows current theme mode', (tester) async {
      await storageService.saveThemeMode('light');
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('淺色'), findsOneWidget);
    });
  });
}
