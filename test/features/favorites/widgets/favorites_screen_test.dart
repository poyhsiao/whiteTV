import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/screens/favorites_screen.dart';

void main() {
  group('FavoritesScreen', () {
    testWidgets('displays page title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FavoritesScreen())),
      );

      expect(find.text('我的收藏'), findsOneWidget);
    });

    testWidgets('has view toggle button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FavoritesScreen())),
      );

      // Initial state is grid view (isGridView=true), so shows list icon
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('has filter bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FavoritesScreen())),
      );

      expect(find.text('全部'), findsOneWidget);
    });

    testWidgets('shows empty state when no favorites', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FavoritesScreen())),
      );

      expect(find.text('還沒有收藏任何內容'), findsOneWidget);
    });
  });
}