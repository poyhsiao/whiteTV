import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/category/category_screen.dart';
import 'package:white_tv/features/category/category_content_store.dart';
import 'package:white_tv/core/api/mock_client.dart';

void main() {
  group('CategoryScreen TV layout', () {
    testWidgets('renders category screen with TV layout on wide screen',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryContentStoreProvider.overrideWith((ref) {
              return CategoryContentStore(MockClient(), 'movie');
            }),
          ],
          child: const MaterialApp(
            home: CategoryScreen(categoryId: 'movie'),
          ),
        ),
      );

      // Process microtask, start loading
      await tester.pump();
      // Let mock delay complete (300ms)
      await tester.pump(const Duration(milliseconds: 500));
      // Consume any remaining pending timers
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('電影'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('TV layout shows subcategory chips', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryContentStoreProvider.overrideWith((ref) {
              return CategoryContentStore(MockClient(), 'movie');
            }),
          ],
          child: const MaterialApp(
            home: CategoryScreen(categoryId: 'movie'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ChoiceChip), findsWidgets);
    });
  });

  group('CategoryScreen Mobile layout', () {
    testWidgets('renders with mobile layout on narrow screen',
        (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryContentStoreProvider.overrideWith((ref) {
              return CategoryContentStore(MockClient(), 'movie');
            }),
          ],
          child: const MaterialApp(
            home: CategoryScreen(categoryId: 'movie'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ExpansionTile), findsWidgets);
      expect(find.text('電影'), findsOneWidget);
    });

    testWidgets('mobile expandable filter shows options when tapped',
        (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryContentStoreProvider.overrideWith((ref) {
              return CategoryContentStore(MockClient(), 'movie');
            }),
          ],
          child: const MaterialApp(
            home: CategoryScreen(categoryId: 'movie'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('動作'), findsOneWidget);
    });
  });

  group('CategoryScreen loading state', () {
    testWidgets('shows loading indicator while loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryContentStoreProvider.overrideWith((ref) {
              return CategoryContentStore(MockClient(), 'movie');
            }),
          ],
          child: const MaterialApp(
            home: CategoryScreen(categoryId: 'movie'),
          ),
        ),
      );

      // Process microtask — loadContent starts synchronously setting isLoading=true
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Drain pending timers to avoid assertion error on teardown
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
