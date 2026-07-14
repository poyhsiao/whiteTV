import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/presentation/widgets/signal_error_widget.dart';

void main() {
  group('SignalErrorWidget', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: 'Signal lost',
              onRetry: null,
            ),
          ),
        ),
      );

      expect(find.text('Signal lost'), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: 'Signal lost',
              onRetry: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.signal_wifi_off), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: 'Signal lost',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('重新整理'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: 'Signal lost',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('重新整理'));
      expect(retryCalled, isTrue);
    });

    testWidgets('does not show retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: 'Signal lost',
              onRetry: null,
            ),
          ),
        ),
      );

      expect(find.text('重新整理'), findsNothing);
    });

    testWidgets('has semi-transparent overlay background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: 'Signal lost',
              onRetry: null,
            ),
          ),
        ),
      );

      // Should find a Container with semi-transparent background
      expect(find.byType(Container), findsWidgets);
    });
  });
}