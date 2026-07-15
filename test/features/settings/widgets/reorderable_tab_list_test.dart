import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/reorderable_tab_list.dart';

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      child: const MaterialApp(
        home: Scaffold(body: ReorderableTabList()),
      ),
    );
  }

  group('ReorderableTabList', () {
    testWidgets('renders all six default tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('首頁'), findsOneWidget);
      expect(find.text('分類'), findsOneWidget);
      expect(find.text('直播'), findsOneWidget);
      expect(find.text('搜尋'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('設定'), findsOneWidget);
    });

    testWidgets('shows drag handle icon for each tab', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.drag_handle), findsNWidgets(6));
    });

    testWidgets('shows visibility icon for each tab', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // All default tabs are visible, so visibility icons should be shown
      expect(find.byIcon(Icons.visibility), findsNWidgets(6));
    });

    testWidgets('toggles tab visibility when visibility icon is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the visibility icon for "首頁"
      final homeTab = find.widgetWithText(ListTile, '首頁');
      final visibilityButton = find.descendant(
        of: homeTab,
        matching: find.byIcon(Icons.visibility),
      );
      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      // After toggling, the icon should change to visibility_off
      final homeTabAfter = find.widgetWithText(ListTile, '首頁');
      final hiddenIcon = find.descendant(
        of: homeTabAfter,
        matching: find.byIcon(Icons.visibility_off),
      );
      expect(hiddenIcon, findsOneWidget);
    });

    testWidgets('shows hint text at bottom', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('長按拖曳可調整順序'), findsOneWidget);
    });

    testWidgets('hint text has grey color', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final hintText = tester.widget<Text>(find.text('長按拖曳可調整順序'));
      expect(hintText.style?.color, Colors.grey);
    });

    testWidgets('all tabs are visible by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // All 6 visibility icons should be "visible" (not hidden)
      expect(find.byIcon(Icons.visibility), findsNWidgets(6));
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('can toggle multiple tabs visibility independently',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Toggle "首頁" to hidden
      final homeTile = find.widgetWithText(ListTile, '首頁');
      await tester.tap(find.descendant(
        of: homeTile,
        matching: find.byIcon(Icons.visibility),
      ));
      await tester.pumpAndSettle();

      // Toggle "分類" to hidden
      final categoriesTile = find.widgetWithText(ListTile, '分類');
      await tester.tap(find.descendant(
        of: categoriesTile,
        matching: find.byIcon(Icons.visibility),
      ));
      await tester.pumpAndSettle();

      // Both should be hidden, rest visible
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility), findsNWidgets(4));
    });

    testWidgets('toggling visibility does not change tab order', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Toggle "首頁" to hidden
      final homeTile = find.widgetWithText(ListTile, '首頁');
      await tester.tap(find.descendant(
        of: homeTile,
        matching: find.byIcon(Icons.visibility),
      ));
      await tester.pumpAndSettle();

      // Order should still be the same
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsNWidgets(6));

      // First tile is still "首頁"
      final firstTitle = tester.widget<ListTile>(listTiles.first);
      expect((firstTitle.title as Text).data, '首頁');
    });
  });
}
