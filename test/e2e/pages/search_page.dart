import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class SearchPage extends BasePage {
  SearchPage(super.tester);

  static const searchInputKey = Key('search_input');

  /// Enter search query
  Future<void> search(String query) async {
    await tester.enterText(find.byKey(searchInputKey), query);
    await tester.pumpAndSettle();
  }

  /// Tap first result
  Future<void> tapFirstResult() async {
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
  }
}
