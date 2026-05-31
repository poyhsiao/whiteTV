import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/theme/colors.dart';
import 'package:white_tv/features/player/widgets/fullscreen_toggle.dart';

void main() {
  group('FullscreenToggle', () {
    testWidgets('shows fullscreen icon when not fullscreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenToggle(
              isFullscreen: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });

    testWidgets('shows fullscreen exit icon when fullscreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenToggle(
              isFullscreen: true,
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    });

    testWidgets('calls onToggle when pressed', (tester) async {
      var toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenToggle(
              isFullscreen: false,
              onToggle: () {
                toggled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(toggled, isTrue);
    });

    testWidgets('uses AppColors.textPrimary for icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenToggle(
              isFullscreen: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.fullscreen));
      expect(iconWidget.color, equals(AppColors.textPrimary));
    });

    testWidgets('shows tooltip "全螢幕" when not fullscreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenToggle(
              isFullscreen: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.tooltip, equals('全螢幕'));
    });

    testWidgets('shows tooltip "退出全螢幕" when fullscreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenToggle(
              isFullscreen: true,
              onToggle: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.tooltip, equals('退出全螢幕'));
    });
  });
}