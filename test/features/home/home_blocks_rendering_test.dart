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
  group('HomeScreen homeBlocks rendering', () {
    testWidgets('hides recommendation when showAIRecommend is false', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await storage.saveHomeBlocks({
        'showRecentWatch': true,
        'showLive': true,
        'showCategories': true,
        'showAIRecommend': false,
        'showHotMovies': true,
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
      // Allow async init to complete without waiting for all timers
      await tester.pump(const Duration(seconds: 3));

      // Recommendation carousel should NOT be visible
      expect(find.text('為你推薦'), findsNothing);
    });
  });
}
