import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/home/widgets/recent_continue_section.dart';

void main() {
  group('RecentContinueSection', () {
    testWidgets('shows nothing when no continue records', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: RecentContinueSection())),
        ),
      );
      expect(find.text('继续观看'), findsNothing);
    });
  });
}
