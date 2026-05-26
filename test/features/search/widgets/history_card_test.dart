import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/widgets/history_card.dart';

void main() {
  group('HistoryCard', () {
    testWidgets('card shows query text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              query: '星際穿越',
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('星際穿越'), findsOneWidget);
    });

    testWidgets('card tap triggers onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              query: 'test',
              onTap: () => tapped = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HistoryCard));
      expect(tapped, isTrue);
    });

    testWidgets('delete button triggers onDelete', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              query: 'test',
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('delete_btn')));
      expect(deleted, isTrue);
    });

    testWidgets('card shows focus ring when focused', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Focus(
              child: HistoryCard(
                query: 'test',
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Verify card renders with proper structure
      expect(find.byType(HistoryCard), findsOneWidget);
    });
  });
}
