import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/home/home_screen.dart';
import 'package:white_tv/features/home/home_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';

void main() {
  group('HomeScreen live entry section', () {
    testWidgets('shows live entry when showLive is true', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await storage.saveHomeBlocks({
        'showRecentWatch': false,
        'showLive': true,
        'showCategories': false,
        'showAIRecommend': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(storage),
            apiClientProvider.overrideWithValue(MockClient()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byKey(const Key('live_entry_section')), findsOneWidget);
      expect(find.text('📺 直播'), findsOneWidget);
    });

    testWidgets('hides live entry when showLive is false', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await storage.saveHomeBlocks({
        'showRecentWatch': false,
        'showLive': false,
        'showCategories': false,
        'showAIRecommend': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(storage),
            apiClientProvider.overrideWithValue(MockClient()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byKey(const Key('live_entry_section')), findsNothing);
    });

    testWidgets('hides live entry by default when showLive not set',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await storage.saveHomeBlocks({
        'showRecentWatch': false,
        'showLive': false,
        'showCategories': false,
        'showAIRecommend': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(storage),
            apiClientProvider.overrideWithValue(MockClient()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byKey(const Key('live_entry_section')), findsNothing);
    });
  });
}
