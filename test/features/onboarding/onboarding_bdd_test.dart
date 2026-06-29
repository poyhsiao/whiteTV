import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

class MockSettingsStorageService extends Mock implements SettingsStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Feature (BDD)', () {
    late MockSettingsStorageService mockStorage;

    setUp(() {
      mockStorage = MockSettingsStorageService();
      when(() => mockStorage.getLunaTVUrl()).thenAnswer((_) async => null);
      when(() => mockStorage.getThemeMode()).thenAnswer((_) async => 'dark');
      when(() => mockStorage.getAutoPlay()).thenAnswer((_) async => true);
      when(() => mockStorage.getDefaultQuality()).thenAnswer((_) async => 'auto');
      when(() => mockStorage.getAutoSelectSource()).thenAnswer((_) async => true);
      when(() => mockStorage.getBlockedSources()).thenAnswer((_) async => []);
      when(() => mockStorage.getHomeBlocks()).thenAnswer((_) async => {});
      when(() => mockStorage.getTabOrder()).thenAnswer((_) async => []);
      when(() => mockStorage.getTimeshiftBufferDuration()).thenAnswer((_) async => 30);
      when(() => mockStorage.saveLunaTVUrl(any())).thenAnswer((_) async {});
    });

    // ======== Scenario: 首次啟動顯示歡迎頁 ========
    testWidgets('''
      Given 用戶首次啟動 App
      Then 應該顯示歡迎頁
      And 應該顯示 "歡迎使用 whiteTV"
    ''', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      expect(find.text('歡迎使用 whiteTV'), findsOneWidget);
    });

    // ======== Widget: 頁面內容 ========
    testWidgets('第一頁顯示播放圖標和功能介紹', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_circle), findsOneWidget);
      expect(find.text('享受來自 LunaTV 的精彩影視內容'), findsOneWidget);
    });

    // ======== Scenario: 點擊開始設定到 URL 輸入頁 ========
    testWidgets('''
      Given 歡迎頁顯示中
      When 點擊 "開始設定"
      Then 應該顯示 URL 輸入框
    ''', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Initial state
      expect(find.text('歡迎使用 whiteTV'), findsOneWidget);

      // Tap start button
      await tester.tap(find.text('開始設定'));
      await tester.pumpAndSettle();

      // Should show URL input page
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('確認'), findsOneWidget);
    });

    // ======== Scenario: URL 輸入 ========
    testWidgets('''
      Given 在 URL 輸入頁
      When 輸入 URL
      Then TextField 應該顯示輸入的內容
    ''', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to URL input page
      await tester.tap(find.text('開始設定'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField.first, 'https://lunatv.example.com');
      await tester.pump();

      expect(find.text('https://lunatv.example.com'), findsWidgets);
    });

    // ======== Scenario: 完成頁顯示 ========
    testWidgets('''
      Given 完成設定
      Then 應該顯示設定完成
    ''', (tester) async {
      // This test requires SettingsStore state which is complex to mock
      // Skip for now - covered by integration tests
    }, skip: true);
  });
}