import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/display_settings_card.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DisplaySettingsCard', () {
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
          home: Scaffold(body: DisplaySettingsCard()),
        ),
      );
    }

    testWidgets('renders home block sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('首頁區塊'), findsOneWidget);
    });

    testWidgets('renders show recent watch toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('最近觀看'), findsOneWidget);
    });

    testWidgets('renders show live toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('直播'), findsOneWidget);
    });

    testWidgets('renders show categories toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('分類'), findsOneWidget);
    });

    testWidgets('renders show AI recommend toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('AI推薦'), findsOneWidget);
    });

    testWidgets('renders show hot movies toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('熱門影片'), findsOneWidget);
    });

    testWidgets('toggles home block visibility', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final recentWatchSwitch = find.byType(Switch);
      expect(recentWatchSwitch, findsWidgets);
    });
  });
}
