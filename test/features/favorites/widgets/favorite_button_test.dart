import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoriteButton', () {
    testWidgets('shows unfilled icon when not favorite', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FavoriteButton(
                itemId: '1',
                title: 'Test Movie',
                posterUrl: 'http://test.com/poster.jpg',
                type: 'movie',
                isFavorite: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows filled icon when favorite', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FavoriteButton(
                itemId: '1',
                title: 'Test Movie',
                posterUrl: 'http://test.com/poster.jpg',
                type: 'movie',
                isFavorite: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('icon is red when favorited', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FavoriteButton(
                itemId: '1',
                title: 'Test Movie',
                posterUrl: 'http://test.com/poster.jpg',
                type: 'movie',
                isFavorite: true,
              ),
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.red);
    });
  });
}
