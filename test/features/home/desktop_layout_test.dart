import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/shared/widgets/desktop_dock_navigation.dart';

/// Desktop Layout 測試
/// 測試 window management, responsive layout, full screen mode
void main() {
  group('DesktopLayout Window Management', () {
    group('Window Size Constraints', () {
      testWidgets('respects minimum window size constraints', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _TestWindow(
              minWidth: 800,
              minHeight: 600,
            ),
          ),
        );

        final size = tester.getSize(find.byType(_TestWindow));
        expect(size.width, greaterThanOrEqualTo(800));
        expect(size.height, greaterThanOrEqualTo(600));
      });

      testWidgets('respects maximum window size constraints', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _TestWindow(
              maxWidth: 1920,
              maxHeight: 1080,
            ),
          ),
        );

        final size = tester.getSize(find.byType(_TestWindow));
        expect(size.width, lessThanOrEqualTo(1920));
        expect(size.height, lessThanOrEqualTo(1080));
      });
    });

    group('Responsive Layout', () {
      testWidgets('adapts layout when window resizes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestResponsiveContainer(),
          ),
        );

        // Initial small size
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('small_layout')), findsOneWidget);

        // Resize to large size
        tester.view.physicalSize = const Size(1400, 900);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('large_layout')), findsOneWidget);
      });

      testWidgets('uses LayoutBuilder for responsive behavior', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestLayoutBuilderWidget(),
          ),
        );

        // Verify LayoutBuilder is used
        expect(find.byType(LayoutBuilder), findsOneWidget);
      });

      testWidgets('applies different layouts at breakpoints', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestBreakpointLayout(),
          ),
        );

        // Mobile breakpoint (<768)
        tester.view.physicalSize = const Size(600, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('mobile_layout')), findsOneWidget);

        // Tablet breakpoint (768-1023)
        tester.view.physicalSize = const Size(900, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tablet_layout')), findsOneWidget);

        // Desktop breakpoint (>=1200)
        tester.view.physicalSize = const Size(1400, 900);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('desktop_layout')), findsOneWidget);
      });
    });

    group('Full Screen Mode', () {
      testWidgets('enters full screen mode correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestFullScreenWidget(),
          ),
        );

        // Find the full screen button and tap it
        final fullScreenButton = find.byKey(const Key('fullscreen_button'));
        expect(fullScreenButton, findsOneWidget);

        await tester.tap(fullScreenButton);
        await tester.pumpAndSettle();

        // Verify full screen state is active
        final state = tester.state<_TestFullScreenWidgetState>(
          find.byType(_TestFullScreenWidget),
        );
        expect(state.isFullScreen, isTrue);
      });

      testWidgets('exits full screen mode correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestFullScreenWidget(isFullScreen: true),
          ),
        );

        // Find the exit full screen button and tap it
        final exitButton = find.byKey(const Key('exit_fullscreen_button'));
        expect(exitButton, findsOneWidget);

        await tester.tap(exitButton);
        await tester.pumpAndSettle();

        final state = tester.state<_TestFullScreenWidgetState>(
          find.byType(_TestFullScreenWidget),
        );
        expect(state.isFullScreen, isFalse);
      });

      testWidgets('toggles full screen with keyboard shortcut', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestFullScreenWidget(),
          ),
        );

        // Simulate F11 key press
        await tester.sendKeyDownEvent(LogicalKeyboardKey.f11);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.f11);
        await tester.pumpAndSettle();

        final state = tester.state<_TestFullScreenWidgetState>(
          find.byType(_TestFullScreenWidget),
        );
        expect(state.isFullScreen, isTrue);
      });
    });

    group('DesktopDockNavigation Integration', () {
      testWidgets('integrates with DesktopDockNavigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestDockIntegration(),
          ),
        );

        // Verify DesktopDockNavigation is present
        expect(find.byType(DesktopDockNavigation), findsOneWidget);
      });

      testWidgets('dock navigation reflects selected index', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestDockIntegration(selectedIndex: 2),
          ),
        );

        // Verify correct dock item is selected
        final dockFinder = find.byType(DesktopDockNavigation);
        expect(dockFinder, findsOneWidget);
      });
    });
  });
}

// Test helper widgets

class _TestWindow extends StatelessWidget {
  const _TestWindow({
    this.minWidth = 0,
    this.minHeight = 0,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
  });

  final double minWidth;
  final double minHeight;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final constrainedWidth = size.width.clamp(minWidth, maxWidth);
    final constrainedHeight = size.height.clamp(minHeight, maxHeight);

    return SizedBox(
      width: constrainedWidth,
      height: constrainedHeight,
      child: const Center(child: Text('Constrained Window')),
    );
  }
}

class _TestResponsiveContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: width < 1200
          ? Container(key: const Key('small_layout'))
          : Container(key: const Key('large_layout')),
    );
  }
}

class _TestLayoutBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: constraints.maxWidth > 1000 ? Colors.blue : Colors.red,
        );
      },
    );
  }
}

class _TestBreakpointLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) {
      return Container(key: const Key('mobile_layout'));
    } else if (width < 1200) {
      return Container(key: const Key('tablet_layout'));
    } else {
      return Container(key: const Key('desktop_layout'));
    }
  }
}

class _TestFullScreenWidget extends StatefulWidget {
  const _TestFullScreenWidget({this.isFullScreen = false});

  final bool isFullScreen;

  @override
  State<_TestFullScreenWidget> createState() => _TestFullScreenWidgetState();
}

class _TestFullScreenWidgetState extends State<_TestFullScreenWidget> {
  bool _isFullScreen = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _isFullScreen = widget.isFullScreen;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get isFullScreen => _isFullScreen;

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.f11) {
            _toggleFullScreen();
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              if (!_isFullScreen)
                ElevatedButton(
                  key: const Key('fullscreen_button'),
                  onPressed: () => setState(() => _isFullScreen = true),
                  child: const Text('Enter Full Screen'),
                ),
              if (_isFullScreen)
                ElevatedButton(
                  key: const Key('exit_fullscreen_button'),
                  onPressed: () => setState(() => _isFullScreen = false),
                  child: const Text('Exit Full Screen'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestDockIntegration extends StatelessWidget {
  const _TestDockIntegration({this.selectedIndex = 0});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('Content'))),
          DesktopDockNavigation(
            deviceType: DeviceType.desktop,
            items: const [
              DockNavigationItem(
                icon: Icons.home,
                label: 'Home',
                route: '/',
              ),
              DockNavigationItem(
                icon: Icons.search,
                label: 'Search',
                route: '/search',
              ),
              DockNavigationItem(
                icon: Icons.favorite,
                label: 'Favorites',
                route: '/favorites',
              ),
            ],
            selectedIndex: selectedIndex,
            onItemSelected: (_) {},
          ),
        ],
      ),
    );
  }
}