import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_grid.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoriteGrid', () {
    testWidgets('displays grid of items', (tester) async {
      final items = [
        FavoriteItem(id: '1', title: '電影1', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: '電影2', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
        FavoriteItem(id: '3', title: '電影3', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
        FavoriteItem(id: '4', title: '電影4', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteGrid(items: items))),
      );

      expect(find.text('電影1'), findsOneWidget);
      expect(find.text('電影2'), findsOneWidget);
    });

    testWidgets('shows unavailable badge for unavailable items', (tester) async {
      final items = [
        FavoriteItem(id: '1', title: '電影1', posterUrl: '', type: 'movie', isAvailable: false, addedAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteGrid(items: items))),
      );

      expect(find.text('已下架'), findsOneWidget);
    });

    testWidgets('calls onTap with correct item id', (tester) async {
      String? tappedId;
      final items = [
        FavoriteItem(id: '1', title: '電影1', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteGrid(
          items: items,
          onTap: (id) => tappedId = id,
        ))),
      );

      await tester.tap(find.text('電影1'));
      expect(tappedId, '1');
    });
  });
}
