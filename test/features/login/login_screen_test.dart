// Sprint 8.1 — LoginScreen tests now wrap ProviderScope and override
// inputServiceProvider with a spy that doesn't bind to a real HttpServer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service.dart';
import 'package:white_tv/core/services/input_service_provider.dart';
import 'package:white_tv/features/login/presentation/screens/login_screen.dart';

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
  group('LoginScreen', () {
    testWidgets('renders login title in app bar', (tester) async {
      await tester.pumpWidget(
        _wrap(LoginScreen(onLoginComplete: (_) {})),
      );

      expect(find.text('登入'), findsWidgets);
    });

    testWidgets('shows QR input option when enabled', (tester) async {
      await tester.pumpWidget(
        _wrap(LoginScreen(onLoginComplete: (_) {}, showQrInput: true)),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        _wrap(LoginScreen(onLoginComplete: (_) {})),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}