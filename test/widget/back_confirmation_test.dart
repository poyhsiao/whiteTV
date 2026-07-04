// TDD 紅階段: TV Back 鍵確認 widget 測試
// 規範: docs/spec/UI_UX.md §15.1
// 預期行為:
// 1. 第一次按 Back → SnackBar「再按一次退出」(不退出)
// 2. 第二次按 Back (2 秒內) → 觸發 onConfirmExit callback
// 3. 2 秒後按 Back → 重設計時,顯示 SnackBar

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/shared/widgets/back_confirmation.dart';

void main() {
  group('BackConfirmation', () {
    testWidgets('第一次按 Back 顯示 SnackBar 且不退出', (tester) async {
      var exitCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BackConfirmation(
            onConfirmExit: () => exitCount++,
            child: const Scaffold(body: Text('home')),
          ),
        ),
      );

      // 模擬 Back 鍵
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pump();

      expect(exitCount, 0, reason: '第一次按 Back 不應觸發 onConfirmExit');
      expect(find.text('再按一次退出 whiteTV'), findsOneWidget);
    });

    testWidgets('第二次按 Back (2 秒內) 觸發 onConfirmExit', (tester) async {
      var exitCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BackConfirmation(
            onConfirmExit: () => exitCount++,
            child: const Scaffold(body: Text('home')),
          ),
        ),
      );

      final NavigatorState navigator = tester.state(find.byType(Navigator));
      // 第一次
      await navigator.maybePop();
      await tester.pump();
      // 第二次 (1 秒內)
      await tester.pump(const Duration(milliseconds: 500));
      await navigator.maybePop();
      await tester.pump();

      expect(exitCount, 1, reason: '第二次按 Back 應觸發 onConfirmExit');
    });

    testWidgets('超過 2 秒後按 Back 重設計時', (tester) async {
      var exitCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BackConfirmation(
            onConfirmExit: () => exitCount++,
            child: const Scaffold(body: Text('home')),
          ),
        ),
      );

      final NavigatorState navigator = tester.state(find.byType(Navigator));
      // 第一次
      await navigator.maybePop();
      await tester.pump();
      // 等超過 2 秒
      await tester.pump(const Duration(seconds: 3));
      // 再按一次 (應重設計時,不退出)
      await navigator.maybePop();
      await tester.pump();

      expect(exitCount, 0, reason: '超過 2 秒後再按 Back 不應退出');
      expect(find.text('再按一次退出 whiteTV'), findsOneWidget);
    });
  });
}
