import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/widgets/category_filter.dart';

void main() {
  group('CategoryFilter', () {
    testWidgets('displays all category chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilter(
              selectedCategory: SearchCategory.all,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('全部'), findsOneWidget);
      expect(find.text('电影'), findsOneWidget);
      expect(find.text('剧集'), findsOneWidget);
      expect(find.text('动漫'), findsOneWidget);
      expect(find.text('综艺'), findsOneWidget);
    });

    testWidgets('shows selected chip as selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilter(
              selectedCategory: SearchCategory.movie,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      // Find all ChoiceChip widgets
      final chips = find.byType(ChoiceChip);
      expect(chips, findsNWidgets(5));

      // The movie chip should be selected (index 1)
      final movieChip = tester.widget<ChoiceChip>(chips.at(1));
      expect(movieChip.selected, isTrue);
    });

    testWidgets('calls onCategorySelected when chip is tapped', (tester) async {
      SearchCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilter(
              selectedCategory: SearchCategory.all,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
            ),
          ),
        ),
      );

      // Tap on the anime chip (index 3)
      await tester.tap(find.text('动漫'));
      await tester.pump();

      expect(selectedCategory, equals(SearchCategory.anime));
    });
  });
}