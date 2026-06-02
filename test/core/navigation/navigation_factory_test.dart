import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/core/navigation/navigation_factory.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';

// Mock navigation widgets for testing
class MockSidebarNavigation extends StatelessWidget {
  const MockSidebarNavigation({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('sidebar'));
}

class MockDesktopDockNavigation extends StatelessWidget {
  const MockDesktopDockNavigation({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('desktop_dock'));
}

class MockMobileNavigation extends StatelessWidget {
  const MockMobileNavigation({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('mobile'));
}

class MockTVNavigation extends StatelessWidget {
  const MockTVNavigation({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('tv'));
}

void main() {
  group('NavigationFactory', () {
    group('getNavigation returns correct navigation for each device type', () {
      testWidgets('returns SidebarNavigation for tablet (width 768-1023)',
          (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  // Override navigation factory for testing
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('sidebar')), findsOneWidget);
        expect(find.byKey(const Key('desktop_dock')), findsNothing);
        expect(find.byKey(const Key('mobile')), findsNothing);
        expect(find.byKey(const Key('tv')), findsNothing);
      });

      testWidgets(
          'returns DesktopDockNavigation for desktop (width >= 1200)',
          (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('desktop_dock')), findsOneWidget);
        expect(find.byKey(const Key('sidebar')), findsNothing);
        expect(find.byKey(const Key('mobile')), findsNothing);
        expect(find.byKey(const Key('tv')), findsNothing);
      });

      testWidgets('returns MobileNavigation for mobile (width < 768)',
          (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('mobile')), findsOneWidget);
        expect(find.byKey(const Key('sidebar')), findsNothing);
        expect(find.byKey(const Key('desktop_dock')), findsNothing);
        expect(find.byKey(const Key('tv')), findsNothing);
      });

      testWidgets('returns TVNavigation for TV (width 1024-1199)', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1100, 1080)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('tv')), findsOneWidget);
        expect(find.byKey(const Key('sidebar')), findsNothing);
        expect(find.byKey(const Key('desktop_dock')), findsNothing);
        expect(find.byKey(const Key('mobile')), findsNothing);
      });
    });

    group('boundary conditions', () {
      testWidgets('returns tablet at width 768 exactly', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 600)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('sidebar')), findsOneWidget);
      });

      testWidgets('returns mobile at width 767', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(767, 600)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('mobile')), findsOneWidget);
      });

      testWidgets('returns tv at width 1024 exactly', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1024, 768)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('tv')), findsOneWidget);
      });

      testWidgets('returns desktop at width 1200 exactly', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('desktop_dock')), findsOneWidget);
      });
    });

    group('backward compatibility', () {
      testWidgets('works without explicit tvNav (falls back to mobile)',
          (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1100, 1080)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        // When tvNav is null, should return mobile navigation as fallback
        expect(find.byKey(const Key('mobile')), findsOneWidget);
      });

      testWidgets('works with all parameters provided', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final widget = NavigationFactory.getNavigation(
                    context,
                    tabletNav: const MockSidebarNavigation(),
                    desktopNav: const MockDesktopDockNavigation(),
                    mobileNav: const MockMobileNavigation(),
                    tvNav: const MockTVNavigation(),
                  );
                  return widget;
                },
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('sidebar')), findsOneWidget);
      });
    });

    testWidgets('TVNavigation renders tabs from default tabOrder', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: TVNavigation(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('首頁'), findsOneWidget);
      expect(find.text('分類'), findsOneWidget);
      expect(find.text('直播'), findsOneWidget);
      expect(find.text('搜尋'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('設定'), findsOneWidget);
    });

    group('DeviceType detection integration', () {
      testWidgets('correctly detects all four device types', (tester) async {
        // Test TV detection
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1100, 1080)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(
                    DeviceUtils.getDeviceType(context),
                    DeviceType.tv,
                  );
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // Test Mobile detection
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(
                    DeviceUtils.getDeviceType(context),
                    DeviceType.mobile,
                  );
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // Test Tablet detection
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(
                    DeviceUtils.getDeviceType(context),
                    DeviceType.tablet,
                  );
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // Test Desktop detection
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(
                    DeviceUtils.getDeviceType(context),
                    DeviceType.desktop,
                  );
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      });
    });
  });
}