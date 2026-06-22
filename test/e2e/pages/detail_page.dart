import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class DetailPage extends BasePage {
  DetailPage(super.tester);

  static const playButtonKey = Key('play_button');
  static const sourceListKey = Key('source_list');

  /// Tap play button
  Future<void> tapPlay() async {
    await tester.tap(find.byKey(playButtonKey));
    await tester.pumpAndSettle();
  }

  /// Select first source
  Future<void> selectFirstSource() async {
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
  }
}
