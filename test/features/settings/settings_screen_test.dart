import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders TabBar with 4 tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SettingsScreen())),
      );

      expect(find.text('設定'), findsOneWidget);
      expect(find.text('一般'), findsOneWidget);
      expect(find.text('帳號'), findsOneWidget);
      expect(find.text('播放'), findsOneWidget);
      expect(find.text('顯示'), findsOneWidget);
    });

    testWidgets('renders TabBarView with 4 tab content areas', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SettingsScreen())),
      );

      // TabBar should be visible
      final tabBar = find.byType(TabBar);
      expect(tabBar, findsOneWidget);

      // TabBarView should be visible
      final tabBarView = find.byType(TabBarView);
      expect(tabBarView, findsOneWidget);
    });

    testWidgets('TabController is initialized with length 4', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SettingsScreen())),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 4);
    });
  });
}
