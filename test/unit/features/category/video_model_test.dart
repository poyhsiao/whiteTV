import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  group('Video model', () {
    test('fromJson parses year field correctly', () {
      final json = {
        'id': 'test-1',
        'title': 'Test Movie',
        'poster_url': 'https://example.com/poster.jpg',
        'description': 'A test movie',
        'category_id': 'movie',
        'type': 'movie',
        'year': '2024',
      };

      final video = Video.fromJson(json);
      expect(video.year, '2024');
    });

    test('fromJson handles missing year field', () {
      final json = {
        'id': 'test-1',
        'title': 'Test Movie',
        'category_id': 'movie',
        'type': 'movie',
      };

      final video = Video.fromJson(json);
      expect(video.year, isNull);
    });
  });
}
