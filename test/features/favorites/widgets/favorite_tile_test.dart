import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_tile.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoriteTile', () {
    testWidgets('displays title', (tester) async {
      final item = FavoriteItem(
        id: '1',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteTile(item: item))),
      );

      expect(find.text('星際穿越'), findsOneWidget);
    });

    testWidgets('displays type badge', (tester) async {
      final item = FavoriteItem(
        id: '1',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteTile(item: item))),
      );

      expect(find.text('電影'), findsOneWidget);
    });

    testWidgets('shows unavailable badge when isAvailable is false', (tester) async {
      final item = FavoriteItem(
        id: '1',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        isAvailable: false,
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteTile(item: item))),
      );

      expect(find.text('已下架'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final item = FavoriteItem(
        id: '1',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FavoriteTile(
          item: item,
          onTap: () => tapped = true,
        ))),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });
  });
}