import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/theme/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Test Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test Content'), findsOneWidget);
  });

  testWidgets('GlassCard applies padding when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            padding: EdgeInsets.all(16),
            child: Text('Padded Content'),
          ),
        ),
      ),
    );

    expect(find.text('Padded Content'), findsOneWidget);
  });
}