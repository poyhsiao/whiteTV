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
      when(() => mockStorage.saveLunaTVUrl(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveThemeMode(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveAutoPlay(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveDefaultQuality(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveAutoSelectSource(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveBlockedSources(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveHomeBlocks(any())).thenAnswer((_) async {});
    });

    // =========================================================================
    // Scenario: 步驟 1 - 歡迎頁顯示
    // =========================================================================
    group('Scenario: 歡迎頁顯示 (UI_UX.md §15.1)', () {
      testWidgets('''
        GIVEN 用戶首次開啟應用程式
        WHEN OnboardingScreen 顯示
        THEN 應該顯示歡迎標題「歡迎使用 whiteTV」
        AND 顯示副標題「享受來自 LunaTV 的精彩影視內容」
        AND 顯示「開始設定」按鈕
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
        expect(find.text('享受來自 LunaTV 的精彩影視內容'), findsOneWidget);
        expect(find.text('開始設定'), findsOneWidget);
      });

      testWidgets('''
        GIVEN 歡迎頁顯示
        WHEN 用戶點擊「開始設定」
        THEN 應該進入步驟 2（URL 輸入頁）
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

        await tester.tap(find.text('開始設定'));
        await tester.pump();

        // 應該看到 URL 輸入提示
        expect(find.text('請輸入 LunaTV 伺服器地址'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    // =========================================================================
    // Scenario: 步驟 2 - URL 輸入
    // =========================================================================
    group('Scenario: URL 輸入與驗證 (UI_UX.md §15.2)', () {
      testWidgets('''
        GIVEN 用戶在 URL 輸入頁
        WHEN 用戶輸入有效 URL
        THEN 應該顯示輸入的 URL
        AND 「確認」按鈕可點擊
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

        // 跳轉到 URL 輸入頁
        await tester.tap(find.text('開始設定'));
        await tester.pump();

        // 輸入 URL
        final textField = find.byType(TextField);
        await tester.enterText(textField.first, 'https://lunatv.example.com');
        await tester.pump();

        expect(find.text('https://lunatv.example.com'), findsWidgets);
        expect(find.text('確認'), findsOneWidget);
      });

      // 空 URL 驗證測試需要 mock timer 或 fake_async，現有整合測試已覆蓋
    });

    // =========================================================================
    // Scenario: 完成頁顯示 (Future.delayed 需要特殊處理)
    // =========================================================================
    // 完成頁測試涉及 Future.delayed (2 秒後自動跳轉)
    // 建議使用 fake_async 套件來控制時間
    // 現有整合測試 test/features/onboarding/presentation/screens/onboarding_screen_test.dart 已覆蓋
  });
}
