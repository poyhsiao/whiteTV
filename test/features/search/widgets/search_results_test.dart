import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/search/widgets/search_results.dart';

void main() {
  group('SearchResults', () {
    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchResults(
              results: [],
              isLoading: true,
              onResultSelected: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when results is empty and not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchResults(
              results: [],
              isLoading: false,
              onResultSelected: null,
            ),
          ),
        ),
      );

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('displays search results in grid', (tester) async {
      final videos = [
        const Video(id: '1', title: 'Movie 1', posterUrl: null, categoryId: 'cat1', type: 'movie'),
        const Video(id: '2', title: 'Movie 2', posterUrl: null, categoryId: 'cat1', type: 'movie'),
        const Video(id: '3', title: 'Movie 3', posterUrl: null, categoryId: 'cat1', type: 'movie'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResults(
              results: videos,
              isLoading: false,
              onResultSelected: null,
            ),
          ),
        ),
      );

      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Movie 2'), findsOneWidget);
      expect(find.text('Movie 3'), findsOneWidget);
    });

    testWidgets('calls onResultSelected when result is tapped', (tester) async {
      Video? selectedVideo;
      final videos = [
        const Video(id: '1', title: 'Movie 1', posterUrl: null, categoryId: 'cat1', type: 'movie'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResults(
              results: videos,
              isLoading: false,
              onResultSelected: (video) => selectedVideo = video,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Movie 1'));
      expect(selectedVideo?.id, '1');
      expect(selectedVideo?.title, 'Movie 1');
    });
  });
}