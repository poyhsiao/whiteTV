import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  group('Category', () {
    test('fromJson reads required fields and nullable poster', () {
      final json = {
        'id': 'cat-1',
        'name': 'Drama',
        'poster_url': 'https://example.com/p.png',
      };

      final category = Category.fromJson(json);

      expect(category.id, 'cat-1');
      expect(category.name, 'Drama');
      expect(category.posterUrl, 'https://example.com/p.png');
    });

    test('fromJson tolerates missing poster_url', () {
      final category = Category.fromJson({'id': 'c1', 'name': 'C1'});
      expect(category.posterUrl, isNull);
    });

    test('toJson serializes all fields with snake_case keys', () {
      const category = Category(
        id: 'cat-1',
        name: 'Drama',
        posterUrl: 'https://example.com/p.png',
      );

      final json = category.toJson();

      expect(json['id'], 'cat-1');
      expect(json['name'], 'Drama');
      expect(json['poster_url'], 'https://example.com/p.png');
    });
  });

  group('Video', () {
    test('fromJson reads all fields including nullable year', () {
      final video = Video.fromJson({
        'id': 'v1',
        'title': 'Title',
        'poster_url': 'https://example.com/v.png',
        'description': 'desc',
        'category_id': 'cat-1',
        'type': 'movie',
        'year': '2024',
      });

      expect(video.id, 'v1');
      expect(video.title, 'Title');
      expect(video.posterUrl, 'https://example.com/v.png');
      expect(video.description, 'desc');
      expect(video.categoryId, 'cat-1');
      expect(video.type, 'movie');
      expect(video.year, '2024');
    });

    test('fromJson tolerates missing optional fields', () {
      final video = Video.fromJson({
        'id': 'v2',
        'title': 'Title',
        'category_id': 'cat-1',
        'type': 'series',
      });

      expect(video.posterUrl, isNull);
      expect(video.description, isNull);
      expect(video.year, isNull);
    });
  });

  group('Episode', () {
    test('fromJson reads id, number, and optional title', () {
      final episode = Episode.fromJson({
        'id': 'ep-1',
        'number': 3,
        'title': 'Pilot',
      });

      expect(episode.id, 'ep-1');
      expect(episode.number, 3);
      expect(episode.title, 'Pilot');
    });

    test('fromJson tolerates missing title', () {
      final episode = Episode.fromJson({'id': 'ep-1', 'number': 1});
      expect(episode.title, isNull);
    });
  });

  group('VideoSource', () {
    test('fromJson reads id, name, url with sensible defaults', () {
      final source = VideoSource.fromJson({
        'id': 's1',
        'name': 'Source 1',
        'url': 'https://example.com/s1.m3u8',
      });

      expect(source.id, 's1');
      expect(source.name, 'Source 1');
      expect(source.url, 'https://example.com/s1.m3u8');
    });

    test('VideoSource exposes stable ID and name', () {
      const source = VideoSource(
        id: 's1',
        name: 'Source 1',
        url: 'https://example.com/s1.m3u8',
      );

      expect(source.id, 's1');
      expect(source.name, 'Source 1');
      expect(source.url, 'https://example.com/s1.m3u8');
    });
  });

  group('YoutubeVideo', () {
    test('fromJson prefers video_id then id', () {
      final video = YoutubeVideo.fromJson({
        'video_id': 'yt-123',
        'title': 'Test',
      });

      expect(video.id, 'yt-123');
      expect(video.title, 'Test');
    });

    test('fromJson falls back to id when video_id is missing', () {
      final video = YoutubeVideo.fromJson({'id': 'yt-456', 'title': 'Test'});

      expect(video.id, 'yt-456');
    });

    test('fromJson returns empty defaults for missing data', () {
      final video = YoutubeVideo.fromJson({});
      expect(video.id, '');
      expect(video.title, '');
      expect(video.thumbnailUrl, isNull);
    });
  });

  group('YoutubeCategory', () {
    test('fromJson populates id, name, and nullable thumbnail', () {
      final cat = YoutubeCategory.fromJson({
        'id': 'music',
        'name': 'Music',
        'thumbnail_url': 'https://example.com/music.png',
      });

      expect(cat.id, 'music');
      expect(cat.name, 'Music');
      expect(cat.thumbnailUrl, 'https://example.com/music.png');
    });

    test('fromJson defaults to empty strings when fields are missing', () {
      final cat = YoutubeCategory.fromJson({});
      expect(cat.id, '');
      expect(cat.name, '');
      expect(cat.thumbnailUrl, isNull);
    });
  });
}
