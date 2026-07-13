import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/settings/settings_screen.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/core/api/mock_client.dart';

void main() {
  group('SettingsScreen', () {
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
          authStoreProvider.overrideWith((ref) {
            return AuthStore(storageService, MockClient());
          }),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      );
    }

    testWidgets('renders TabBar with 6 tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('設定'), findsAtLeastNWidgets(1));
      expect(find.text('一般'), findsOneWidget);
      expect(find.text('帳號'), findsOneWidget);
      expect(find.text('播放'), findsOneWidget);
      expect(find.text('顯示'), findsOneWidget);
      expect(find.text('首頁區塊'), findsOneWidget);
      expect(find.text('Tab 設定'), findsOneWidget);
    });

    testWidgets('renders TabBarView with 6 tab content areas', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('TabController is initialized with length 6', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 6);
    });
  });
}
