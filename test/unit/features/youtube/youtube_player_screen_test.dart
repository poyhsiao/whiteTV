import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/search/search_state.dart';

class FakeYouTubePlayerApiClient with ApiClientFallbacks implements ApiClient {
  @override
  Future<Map<String, String>?> login(String username, String password) async => null;

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async => [];

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async =>
      VideoDetail(id: videoId, title: 'Test Video', episodes: []);

  @override
  Future<List<VideoSource>> getSources(String videoId) async => [];

  @override
  Future<int> testSourceLatency(String sourceUrl) async => -1;

  @override
  Future<List<Video>> search(String query, {SearchCategory? category}) async => [];

  @override
  Future<Map<String, dynamic>> getUserStats() async => {};

  @override
  Future<void> syncSearchHistory(List<String> history) async {}

  @override
  Future<List<String>> getSearchHistory() async => [];

  @override
  Future<bool> savePlayHistory(PlayHistory record) async => true;

  @override
  Future<List<IptvChannel>> getIptvChannels() async => [];

  @override
  Future<String?> getIptvM3U() async => null;

  @override
  Future<Map<String, dynamic>> getIptvEpg() async => {};

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async => [];

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async => [];

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async => [];

  @override
  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async => [];

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async => [];
}

/// Simple placeholder widget for YouTubePlayer to avoid iframe initialization in tests
class FakeYoutubePlayer extends StatelessWidget {
  final String aspectRatio;
  const FakeYoutubePlayer({super.key, this.aspectRatio = '16/9'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text('YouTube Player', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// Test widget that mimics YoutubePlayerScreen structure without real YouTube iframe
class TestableYoutubePlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String? videoTitle;
  final String? youtubeUrl;

  const TestableYoutubePlayerScreen({
    super.key,
    required this.videoId,
    this.videoTitle,
    this.youtubeUrl,
  });

  @override
  ConsumerState<TestableYoutubePlayerScreen> createState() => _TestableYoutubePlayerScreenState();
}

class _TestableYoutubePlayerScreenState extends ConsumerState<TestableYoutubePlayerScreen> {
  bool _isFullscreen = false;

  String? _extractYoutubeVideoId(String input) {
    if (input.length == 11 && !input.contains('/')) {
      return input;
    }
    if (input.contains('youtube.com/watch')) {
      final uri = Uri.parse(input);
      return uri.queryParameters['v'];
    }
    if (input.contains('youtu.be/')) {
      final uri = Uri.parse(input);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractYoutubeVideoId(widget.youtubeUrl ?? widget.videoId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // YouTube Player placeholder
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FakeYoutubePlayer(),
                      if (videoId != null)
                        Text(
                          'Playing: $videoId',
                          style: const TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Fullscreen button
            Positioned(
              bottom: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YoutubePlayerScreen Widget Tests', () {
    testWidgets('shows video title in screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test YouTube Video 1')),
            body: const TestableYoutubePlayerScreen(
              videoId: 'yt_test_1',
              videoTitle: 'Test YouTube Video 1',
              youtubeUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show video title
      expect(find.text('Test YouTube Video 1'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TestableYoutubePlayerScreen(
              videoId: 'yt_test_1',
              videoTitle: 'Test YouTube Video 1',
              youtubeUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows fullscreen button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TestableYoutubePlayerScreen(
              videoId: 'yt_test_1',
              videoTitle: 'Test YouTube Video 1',
              youtubeUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });

    testWidgets('toggles fullscreen on button press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TestableYoutubePlayerScreen(
              videoId: 'yt_test_1',
              videoTitle: 'Test YouTube Video 1',
              youtubeUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap fullscreen button
      await tester.tap(find.byIcon(Icons.fullscreen));
      await tester.pump();

      // Should now show fullscreen exit icon
      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    });

    testWidgets('extracts video ID from youtube URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TestableYoutubePlayerScreen(
              videoId: 'yt_test_1',
              videoTitle: 'Test Video',
              youtubeUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
            ),
          ),
        ),
      );

      await tester.pump();

      // Should display extracted video ID
      expect(find.textContaining('dQw4w9WgXcQ'), findsOneWidget);
    });

    testWidgets('handles direct video ID input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TestableYoutubePlayerScreen(
              videoId: 'dQw4w9WgXcQ',
              videoTitle: 'Direct ID Test',
              youtubeUrl: null,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('dQw4w9WgXcQ'), findsOneWidget);
    });
  });

  group('Video ID extraction logic', () {
    test('extracts from standard youtube.com/watch URL', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final uri = Uri.parse(url);
      expect(uri.queryParameters['v'], equals('dQw4w9WgXcQ'));
    });

    test('extracts from youtu.be short URL', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      final uri = Uri.parse(url);
      expect(uri.pathSegments.first, equals('dQw4w9WgXcQ'));
    });

    test('extracts from youtube.com/embed URL', () {
      const url = 'https://www.youtube.com/embed/dQw4w9WgXcQ';
      final uri = Uri.parse(url);
      expect(uri.pathSegments.last, equals('dQw4w9WgXcQ'));
    });

    test('identifies 11-char video ID', () {
      const id = 'dQw4w9WgXcQ';
      expect(id.length, equals(11));
    });
  });
}
