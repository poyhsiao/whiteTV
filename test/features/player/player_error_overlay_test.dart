import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/widgets/player_error_overlay.dart';

void main() {
  group('PlayerErrorOverlay', () {
    testWidgets('顯示錯誤訊息', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerErrorOverlay(
            message: '播放失敗',
          ),
        ),
      );

      expect(find.text('播放失敗'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('顯示重試按鈕', (tester) async {
      var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PlayerErrorOverlay(
            message: '播放失敗',
            onRetry: () => retryPressed = true,
          ),
        ),
      );

      expect(find.text('重試'), findsOneWidget);
      await tester.tap(find.text('重試'));
      expect(retryPressed, true);
    });

    testWidgets('顯示選擇來源按鈕', (tester) async {
      var selectPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PlayerErrorOverlay(
            message: '播放失敗',
            onSelectSource: () => selectPressed = true,
          ),
        ),
      );

      expect(find.text('選擇來源'), findsOneWidget);
      await tester.tap(find.text('選擇來源'));
      expect(selectPressed, true);
    });
  });
}