import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/playback_settings_card.dart';
import 'package:white_tv/features/settings/widgets/source_blocklist_tile.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PlaybackSettingsCard', () {
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
          home: Scaffold(body: PlaybackSettingsCard()),
        ),
      );
    }

    testWidgets('renders auto-play toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('自動播放'), findsOneWidget);
    });

    testWidgets('renders default quality selector', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('預設畫質'), findsOneWidget);
    });

    testWidgets('renders auto-select source toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('自動選擇來源'), findsOneWidget);
    });

    testWidgets('renders source blocklist', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SourceBlocklistTile), findsOneWidget);
    });

    testWidgets('shows current auto-play state', (tester) async {
      await storageService.saveAutoPlay(false);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsWidgets);
    });

    testWidgets('shows current quality setting', (tester) async {
      await storageService.saveDefaultQuality('1080p');
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('1080p'), findsOneWidget);
    });
  });
}
