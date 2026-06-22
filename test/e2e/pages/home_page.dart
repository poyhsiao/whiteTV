import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class HomePage extends BasePage {
  HomePage(super.tester);

  /// Key from home_screen.dart
  static const homeScreenKey = Key('home_screen');

  /// Wait for home to load
  Future<void> waitForLoad() async {
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(homeScreenKey), findsOneWidget);
  }

  /// Check if category tab exists
  bool hasCategory(String categoryName) {
    return find.text(categoryName).evaluate().isNotEmpty;
  }
}
