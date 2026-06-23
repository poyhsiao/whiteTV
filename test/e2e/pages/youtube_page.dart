import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class YoutubePage extends BasePage {
  YoutubePage(super.tester);

  /// Navigate to YouTube category screen
  Future<void> navigateToCategory() async {
    await tester.tap(find.byIcon(Icons.video_library));
    await tester.pumpAndSettle();
  }

  /// Get YouTube section widget
  Future<void> scrollToSection() async {
    // Scroll until YouTube section is visible
    await tester.scrollUntilVisible(
      find.text('YouTube'),
      100.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  /// Tap a video by index in the horizontal list
  Future<void> tapVideoAtIndex(int index) async {
    final listFinder = find.byType(ListView);
    await tester.scrollUntilVisible(
      find.byType(ListTile).first,
      100.0,
      scrollable: listFinder,
    );
    await tester.pumpAndSettle();
  }

  /// Verify YouTube section is visible
  Future<void> verifySectionVisible() async {
    expect(find.text('YouTube'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
  }

  /// Tap a category chip by index
  Future<void> tapCategoryAtIndex(int index) async {
    final chips = find.byType(ChoiceChip);
    expect(chips, findsWidgets);
    await tester.tap(chips.at(index));
    await tester.pumpAndSettle();
  }

  /// Verify video grid is displayed
  Future<void> verifyVideoGrid() async {
    await tester.pump(const Duration(seconds: 1));
    // Grid or list should be visible
    expect(
      find.byType(GridView).evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty,
      isTrue,
    );
  }
}
