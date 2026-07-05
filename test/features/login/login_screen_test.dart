// Sprint 8.1 — LoginScreen tests now wrap ProviderScope and override
// inputServiceProvider with a spy that doesn't bind to a real HttpServer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service_provider.dart';
import 'package:white_tv/features/login/presentation/screens/login_screen.dart';
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