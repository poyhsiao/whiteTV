import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';

void main() {
  testWidgets('PosterCard displays title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PosterCard(
            title: '星際穿越',
          ),
        ),
      ),
    );

    expect(find.text('星際穿越'), findsOneWidget);
  });

  testWidgets('PosterCard calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PosterCard(
            title: 'Test Movie',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PosterCard));
    expect(tapped, true);
  });
}