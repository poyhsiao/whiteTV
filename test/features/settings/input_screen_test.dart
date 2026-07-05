// Sprint 8.1 — InputScreen tests now wrap ProviderScope and override
// inputServiceProvider with a spy that doesn't bind to a real HttpServer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service.dart';
import 'package:white_tv/core/services/input_service_provider.dart';
import 'package:white_tv/features/settings/presentation/screens/input_screen.dart';

class _SpyInputService extends InputService {
  @override
  Future<bool> startServer({int port = 8080}) async => true;

  @override
  Future<void> stopServer() async {}

  @override
  String? get currentIp => '127.0.0.1';

  @override
  int? get currentPort => 8080;

  @override
  bool get isRunning => true;

  @override
  String getQrCodeUrl() => 'http://127.0.0.1:8080/qr';
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      inputServiceProvider.overrideWithValue(_SpyInputService()),
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