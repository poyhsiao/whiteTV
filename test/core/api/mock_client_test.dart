import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';

void main() {
  late MockClient client;

  setUp(() {
    client = MockClient();
  });

  group('MockClient', () {
    test('getCategories returns 4 categories', () async {
      final categories = await client.getCategories();
      expect(categories.length, 4);
      expect(categories.map((c) => c.name), contains('電影'));
    });

    test('getVideosByCategory returns videos for movie', () async {
      final videos = await client.getVideosByCategory('movie');
      expect(videos.isNotEmpty, true);
      expect(videos.first.categoryId, 'movie');
    });

    test('getVideoDetail returns detail with episodes and sources', () async {
      final detail = await client.getVideoDetail('movie-1');
      expect(detail.id, 'movie-1');
      expect(detail.episodes.isNotEmpty, true);
      expect(detail.sources.isNotEmpty, true);
    });

    test('getSources returns available sources', () async {
      final sources = await client.getSources('movie-1');
      expect(sources.length, 3);
      expect(sources.every((s) => s.isAvailable), true);
    });

    test('testSourceLatency returns reasonable latency', () async {
      final latency = await client.testSourceLatency('https://example.com');
      expect(latency, greaterThan(0));
      expect(latency, lessThan(500));
    });
  });
}