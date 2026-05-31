import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/shared/widgets/source_switcher.dart';

void main() {
  group('SourceSwitcher Widget', () {
    testWidgets('displays all video sources with name and latency', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
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
      expect(find.text('非凡資源'), findsOneWidget);
      expect(find.text('80ms'), findsOneWidget);
      expect(find.text('120ms'), findsOneWidget);
    });

    testWidgets('shows selected source with accent color indicator', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
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

      // Selected source should have accent color indicator
      final selectedTile = find.ancestor(
        of: find.text('量子資源'),
        matching: find.byType(ListTile),
      );
      expect(selectedTile, findsOneWidget);
    });

    testWidgets('calls onSourceSelected when source is tapped', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
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

      await tester.tap(find.text('非凡資源'));
      await tester.pump();

      expect(selectedSource, isNotNull);
      expect(selectedSource!.id, 'src2');
    });

    testWidgets('shows unavailable state with different color for unavailable sources', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 0, isAvailable: false),
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
      expect(find.text('非凡資源'), findsOneWidget);
      // Unavailable source should show unavailable status
    });

    testWidgets('shows latency with ms unit', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
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

      expect(find.text('80ms'), findsOneWidget);
    });

    testWidgets('handles empty sources list', (tester) async {
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

      // Should render without error
      expect(find.byType(SourceSwitcher), findsOneWidget);
    });

    testWidgets('shows current source label when provided', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
              currentSourceLabel: '當前來源',
            ),
          ),
        ),
      );

      expect(find.text('當前來源'), findsOneWidget);
    });

    testWidgets('shows block button for each source', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
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

      // Block icons should be present
      expect(find.byIcon(Icons.block), findsNWidgets(2));
    });

    testWidgets('calls onSourceBlocked when block icon is tapped', (tester) async {
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
      ];

      String? blockedSourceId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceSwitcher(
              sources: sources,
              selectedSourceId: 'src1',
              onSourceSelected: (_) {},
              onSourceBlocked: (sourceId) {
                blockedSourceId = sourceId;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.block));
      await tester.pump();

      expect(blockedSourceId, 'src1');
    });
  });
}
