import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/presentation/widgets/signal_error_widget.dart';

void main() {
  group('SignalErrorWidget — UI_UX.md §9.7', () {
    testWidgets('displays Chinese error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(message: '訊號異常'),
          ),
        ),
      );
      expect(find.text('訊號異常，請稍後重試'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: '訊號異常',
              onRetry: () {},
            ),
          ),
        ),
      );
      expect(find.text('重新整理'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(message: '訊號異常'),
          ),
        ),
      );
      expect(find.text('重新整理'), findsNothing);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignalErrorWidget(
              message: '訊號異常',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('重新整理'));
      expect(retried, true);
    });
  });
}
