import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base Page Object class with common interactions
abstract class BasePage {
  final WidgetTester tester;

  BasePage(this.tester);

  /// Tap a widget by key or text
  Future<void> tap(String locator) async {
    if (locator.startsWith('#')) {
      await tester.tap(find.byKey(Key(locator.substring(1))));
    } else {
      await tester.tap(find.text(locator));
    }
    await tester.pumpAndSettle();
  }

  /// Enter text into a field
  Future<void> enterText(String locator, String text) async {
    if (locator.startsWith('#')) {
      await tester.enterText(find.byKey(Key(locator.substring(1))), text);
    } else {
      await tester.enterText(find.byType(TextField), text);
    }
    await tester.pumpAndSettle();
  }

  /// Wait for widget to appear
  Future<void> waitFor(String locator, {Duration timeout = const Duration(seconds: 5)}) async {
    await tester.pump(timeout);
    if (locator.startsWith('#')) {
      expect(find.byKey(Key(locator.substring(1))), findsOneWidget);
    } else {
      expect(find.text(locator), findsOneWidget);
    }
  }

  /// Take screenshot (for debugging)
  /// Note: Requires integration_test package with screenshot support.
  /// For flutter_test, use tester.binding.takeScreenshot() via integration_test.
  Future<void> takeScreenshot(String name) async {
    // WidgetTester in flutter_test does not have takeScreenshot.
    // This is a stub for future integration_test usage.
  }
}
