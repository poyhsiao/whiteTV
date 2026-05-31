import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/player/widgets/source_switcher.dart';

void main() {
  group('SourceSwitcher Widget', () {
    testWidgets('displays source name on OutlinedButton', (tester) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('量子資源'), findsOneWidget);
    });

    testWidgets('shows [自動] tag when isAutoSelected is true', (tester) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
              isAutoSelected: true,
            ),
          ),
        ),
      );

      expect(find.text('[自動]'), findsOneWidget);
    });

    testWidgets('does not show [自動] tag when isAutoSelected is false', (
      tester,
    ) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
              isAutoSelected: false,
            ),
          ),
        ),
      );

      expect(find.text('[自動]'), findsNothing);
    });

    testWidgets('opens dialog when button is tapped', (tester) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
        const VideoSource(
          id: 'src2',
          name: '非凡資源',
          url: 'http://b.com',
          latency: 120,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Dialog should show title and sources in dialog (not on button)
      expect(find.text('選擇來源'), findsOneWidget);
      // Use dialog finder to be specific about which text widgets we're checking
      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(of: dialog, matching: find.text('量子資源')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('非凡資源')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('80ms')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('120ms')),
        findsOneWidget,
      );
    });

    testWidgets('shows latency with ms unit in dialog', (tester) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.text('80ms'), findsOneWidget);
    });

    testWidgets('calls onSourceSelected when source is tapped in dialog', (
      tester,
    ) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
        const VideoSource(
          id: 'src2',
          name: '非凡資源',
          url: 'http://b.com',
          latency: 120,
        ),
      ];

      VideoSource? selectedSource;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (source) {
                selectedSource = source;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Tap on the second source
      await tester.tap(find.text('非凡資源'));
      await tester.pumpAndSettle();

      expect(selectedSource, isNotNull);
      expect(selectedSource!.id, 'src2');
      expect(selectedSource!.name, '非凡資源');
    });

    testWidgets('closes dialog when cancel is tapped', (tester) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.text('選擇來源'), findsOneWidget);

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.text('選擇來源'), findsNothing);
    });

    testWidgets('disables button when sources list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: [],
              selectedSourceId: null,
              onSourceSelected: (_) {},
            ),
          ),
        ),
      );

      final outlinedButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(outlinedButton.onPressed, isNull);
    });

    testWidgets('shows check_circle for selected source in dialog', (
      tester,
    ) async {
      final sources = [
        const VideoSource(
          id: 'src1',
          name: '量子資源',
          url: 'http://a.com',
          latency: 80,
        ),
        const VideoSource(
          id: 'src2',
          name: '非凡資源',
          url: 'http://b.com',
          latency: 120,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Selected source should have check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // Unselected source should have circle_outlined icon
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets(
      'button is disabled with null onPressed when sources is empty',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SourceSwitcher(
                sources: const [],
                selectedSourceId: null,
                onSourceSelected: (_) {},
              ),
            ),
          ),
        );

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(button.onPressed, isNull);
      },
    );
  });
}
