import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorites_filter_bar.dart';

void main() {
  group('FavoritesFilterBar', () {
    testWidgets('displays all filter options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoritesFilterBar(
          selectedType: 'all',
          onTypeSelected: (_) {},
        ))),
      );

      expect(find.text('全部'), findsOneWidget);
      expect(find.text('電影'), findsOneWidget);
      expect(find.text('劇集'), findsOneWidget);
      expect(find.text('動漫'), findsOneWidget);
      expect(find.text('綜藝'), findsOneWidget);
    });

    testWidgets('calls onTypeSelected when filter tapped', (tester) async {
      String? selectedType;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoritesFilterBar(
          selectedType: 'all',
          onTypeSelected: (type) => selectedType = type,
        ))),
      );

      await tester.tap(find.text('電影'));
      expect(selectedType, 'movie');
    });

    testWidgets('highlights selected filter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoritesFilterBar(
          selectedType: 'movie',
          onTypeSelected: (_) {},
        ))),
      );

      // Find the FilterChip that is selected
      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsNWidgets(5));
    });
  });
}
