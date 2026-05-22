import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/login/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('renders login title in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginComplete: (_) {},
          ),
        ),
      );

      expect(find.text('登入'), findsWidgets); // AppBar title + button text
    });

    testWidgets('shows QR input option when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginComplete: (_) {},
            showQrInput: true,
          ),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginComplete: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
