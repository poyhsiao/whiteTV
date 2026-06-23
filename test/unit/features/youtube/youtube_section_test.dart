import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart' show YoutubeVideo;
import 'package:white_tv/features/youtube/presentation/widgets/youtube_section.dart';

void main() {
  group('YoutubeSection', () {
    testWidgets('renders section title and video cards', (tester) async {
      final videos = [
        const YoutubeVideo(
          id: 'yt1',
          title: 'Test Video 1',
          thumbnailUrl: 'https://example.com/thumb1.jpg',
          duration: '10:30',
        ),
        const YoutubeVideo(
          id: 'yt2',
          title: 'Test Video 2',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          duration: '05:00',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoutubeSection(videos: videos),
          ),
        ),
      );

      expect(find.text('YouTube'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
      expect(find.text('Test Video 1'), findsOneWidget);
      expect(find.text('Test Video 2'), findsOneWidget);
    });

    testWidgets('shows ListView when videos list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoutubeSection(videos: const []),
          ),
        ),
      );

      expect(find.text('YouTube'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays video duration badges', (tester) async {
      final videos = [
        const YoutubeVideo(
          id: 'yt1',
          title: 'Duration Test',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          duration: '12:34',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoutubeSection(videos: videos),
          ),
        ),
      );

      expect(find.text('12:34'), findsOneWidget);
    });
  });
}
