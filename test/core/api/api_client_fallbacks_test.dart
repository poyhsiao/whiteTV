import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client_fallbacks.dart';

class _FallbackHost extends Object with ApiClientFallbacks {}

void main() {
  group('ApiClientFallbacks', () {
    late _FallbackHost host;

    setUp(() {
      host = _FallbackHost();
    });

    test('getHotMovies returns an empty list by default', () async {
      final result = await host.getHotMovies();
      expect(result, isEmpty);
    });

    test('getHotMovies respects the limit argument', () async {
      final result = await host.getHotMovies(limit: 50);
      expect(result, isEmpty);
    });

    test('getRelatedVideos returns an empty list by default', () async {
      final result = await host.getRelatedVideos('video-123');
      expect(result, isEmpty);
    });

    test('getRelatedVideos respects the limit argument', () async {
      final result = await host.getRelatedVideos('video-123', limit: 5);
      expect(result, isEmpty);
    });

    test('getYoutubeRecommend returns an empty list', () async {
      final result = await host.getYoutubeRecommend();
      expect(result, isEmpty);
    });

    test('getYoutubeList returns an empty list', () async {
      final result = await host.getYoutubeList('cat-1');
      expect(result, isEmpty);
    });

    test('getYoutubeList with page returns an empty list', () async {
      final result = await host.getYoutubeList('cat-1', page: 'next');
      expect(result, isEmpty);
    });

    test('getYoutubeCategories returns an empty list', () async {
      final result = await host.getYoutubeCategories();
      expect(result, isEmpty);
    });
  });
}
