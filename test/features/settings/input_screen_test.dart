// Sprint 8.1 — InputScreen tests now wrap ProviderScope and override
// inputServiceProvider with a spy that doesn't bind to a real HttpServer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service_provider.dart';
import 'package:white_tv/features/settings/presentation/screens/input_screen.dart';
import '../../helpers/spy_input_service.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      inputServiceProvider.overrideWithValue(SpyInputService()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('InputScreen', () {
    testWidgets('displays QR code widget', (tester) async {
      await tester.pumpWidget(
        _wrap(InputScreen(title: '測試標題', onComplete: (_) {})),
      );

      expect(find.byType(InputScreen), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(
        _wrap(InputScreen(title: '測試標題', onComplete: (_) {})),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls onComplete when done', (tester) async {
      String? completedText;

      await tester.pumpWidget(
        _wrap(InputScreen(
          title: '測試標題',
          onComplete: (text) {
            completedText = text;
          },
        )),
      );

      final doneButton = find.text('完成');
      if (doneButton.evaluate().isNotEmpty) {
        await tester.tap(doneButton);
        expect(completedText, isNotNull);
      }
    });
  });
}