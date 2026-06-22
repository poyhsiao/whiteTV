import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class LoginPage extends BasePage {
  LoginPage(super.tester);

  /// Keys from login_screen.dart
  static const usernameKey = Key('username_field');
  static const passwordKey = Key('password_field');
  static const loginButtonKey = Key('login_button');
  static const qrInputKey = Key('qr_input_button');

  /// Enter username
  Future<void> enterUsername(String username) async {
    await tester.enterText(find.byKey(usernameKey), username);
    await tester.pumpAndSettle();
  }

  /// Enter password
  Future<void> enterPassword(String password) async {
    await tester.enterText(find.byKey(passwordKey), password);
    await tester.pumpAndSettle();
  }

  /// Tap login button
  Future<void> tapLogin() async {
    await tester.tap(find.byKey(loginButtonKey));
    await tester.pumpAndSettle();
  }

  /// Login with credentials
  Future<void> login(String username, String password) async {
    await enterUsername(username);
    await enterPassword(password);
    await tapLogin();
  }
}
