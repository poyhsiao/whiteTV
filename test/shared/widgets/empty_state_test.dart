import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders icon, title, subtitle, and action button',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.favorite_border,
              title: '還沒有收藏任何內容',
              subtitle: '開始探索你喜歡的電影和節目',
              actionLabel: '開始探索',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('還沒有收藏任何內容'), findsOneWidget);
      expect(find.text('開始探索你喜歡的電影和節目'), findsOneWidget);
      expect(find.text('開始探索'), findsOneWidget);
    });

    testWidgets('renders without action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.history,
              title: '還沒有觀看記錄',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('還沒有觀看記錄'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('calls onAction when button is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.favorite_border,
              title: '還沒有收藏任何內容',
              actionLabel: '開始探索',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('開始探索'));
      expect(tapped, isTrue);
    });
  });
}
