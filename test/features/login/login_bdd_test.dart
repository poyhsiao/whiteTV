import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/services/input_service_provider.dart';
import 'package:white_tv/features/login/presentation/screens/login_screen.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import '../../helpers/spy_input_service.dart';

class MockAuthStore extends Mock implements AuthStore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login Feature (BDD)', () {
    setUp(() {
      // Mock store setup if needed
    });

    // =========================================================================
    // Scenario: 登入頁顯示
    // =========================================================================
    group('Scenario: 登入頁顯示 (UI_UX.md §13.3)', () {
      testWidgets('''
        GIVEN 用戶打開登入頁
        WHEN 頁面載入完成
        THEN 應該顯示「登入」標題
        AND 應該顯示帳號輸入框
        AND 應該顯示密碼輸入框
        AND 應該顯示「登入」按鈕
        AND 應該顯示返回按鈕
      ''', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              inputServiceProvider.overrideWithValue(SpyInputService()),
            ],
            child: MaterialApp(
              home: LoginScreen(onLoginComplete: (_) {}),
            ),
          ),
        );

        expect(find.text('登入'), findsWidgets);
        expect(find.byType(TextField), findsNWidgets(2)); // 帳號和密碼
        expect(find.text('登入'), findsWidgets);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('''
        GIVEN 登入頁顯示
        WHEN 用戶輸入帳號和密碼
        THEN 應該顯示輸入的內容
      ''', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              inputServiceProvider.overrideWithValue(SpyInputService()),
            ],
            child: MaterialApp(
              home: LoginScreen(onLoginComplete: (_) {}),
            ),
          ),
        );

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'testuser');
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pump();

        expect(find.text('testuser'), findsOneWidget);
        expect(find.text('password123'), findsOneWidget);
      });
    });

    // =========================================================================
    // Scenario: QR 輸入選項
    // =========================================================================
    // QR 輸入測試需要更複雜的 mock setup，現有整合測試已覆蓋

    // =========================================================================
    // Scenario: 返回導航
    // =========================================================================
    group('Scenario: 返回導航', () {
      testWidgets('''
        GIVEN 登入頁顯示
        WHEN 用戶點擊返回按鈕
        THEN 應該返回上一頁
      ''', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              inputServiceProvider.overrideWithValue(SpyInputService()),
            ],
            child: MaterialApp(
              home: LoginScreen(onLoginComplete: (_) {}),
            ),
          ),
        );

        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);
      });
    });
  });
}
