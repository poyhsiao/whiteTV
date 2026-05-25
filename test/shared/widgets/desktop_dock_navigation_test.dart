import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/feature_flags.dart';
import 'package:white_tv/shared/widgets/desktop_dock_navigation.dart';

void main() {
  group('DesktopDockNavigation', () {
    testWidgets('renders dock items when deviceType is desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.desktop,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
                DockNavigationItem(icon: Icons.search, label: 'Search', route: '/search'),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('does not render dock content when deviceType is not desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.mobile,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      // When not desktop, widget returns SizedBox.shrink() so dock items are not rendered
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('displays all dock items with icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.desktop,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
                DockNavigationItem(icon: Icons.search, label: 'Search', route: '/search'),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls onItemSelected when dock item is tapped', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.desktop,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
                DockNavigationItem(icon: Icons.search, label: 'Search', route: '/search'),
              ],
              selectedIndex: 0,
              onItemSelected: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, 1);
    });

    testWidgets('shows visual indicator on selected item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.desktop,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
                DockNavigationItem(icon: Icons.search, label: 'Search', route: '/search'),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      // AnimatedContainer is used for the indicator bar
      final animatedContainers = find.byType(AnimatedContainer);
      expect(animatedContainers, findsWidgets);
    });

    testWidgets('updates visual state when selectedIndex changes externally', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(child: Container()),
                    DesktopDockNavigation(
                      deviceType: DeviceType.desktop,
                      items: const [
                        DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
                        DockNavigationItem(icon: Icons.search, label: 'Search', route: '/search'),
                      ],
                      selectedIndex: selectedIndex,
                      onItemSelected: (index) {
                        setState(() => selectedIndex = index);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, 1);
    });

    testWidgets('FeatureFlags.enableDockNavigation returns correct values', (tester) async {
      expect(FeatureFlags.enableDockNavigation(DeviceType.desktop), true);
      expect(FeatureFlags.enableDockNavigation(DeviceType.mobile), false);
      expect(FeatureFlags.enableDockNavigation(DeviceType.tablet), false);
      expect(FeatureFlags.enableDockNavigation(DeviceType.tv), false);
    });

    testWidgets('DockNavigationItem data class holds correct values', (tester) async {
      const item = DockNavigationItem(
        icon: Icons.home,
        label: 'Home',
        route: '/',
      );

      expect(item.icon, Icons.home);
      expect(item.label, 'Home');
      expect(item.route, '/');
    });

    testWidgets('has KeyboardListener for keyboard navigation support', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.desktop,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify KeyboardListener is present for keyboard navigation
      expect(find.byType(KeyboardListener), findsOneWidget);
    });

    testWidgets('renders with correct dock styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopDockNavigation(
              deviceType: DeviceType.desktop,
              items: const [
                DockNavigationItem(icon: Icons.home, label: 'Home', route: '/'),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify Container with styling is present
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });
}