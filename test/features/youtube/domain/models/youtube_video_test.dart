import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/youtube/domain/models/youtube_video.dart';

void main() {
  group('YoutubeVideo', () {
    test('從 JSON 正確解析', () {
      final json = {
        'id': 'youtube_abc123',
        'title': 'Test Video',
        'thumbnail': 'https://example.com/thumb.jpg',
        'duration': '10:30',
        'url': 'https://example.com/stream.m3u8',
      };

      final video = YoutubeVideo.fromJson(json);
      expect(video.id, 'youtube_abc123');
      expect(video.title, 'Test Video');
      expect(video.thumbnail, 'https://example.com/thumb.jpg');
      expect(video.duration, '10:30');
      expect(video.url, 'https://example.com/stream.m3u8');
    });

    test('toJson 正確序列化', () {
      const video = YoutubeVideo(
        id: 'youtube_abc123',
        title: 'Test Video',
        thumbnail: 'https://example.com/thumb.jpg',
        duration: '10:30',
        url: 'https://example.com/stream.m3u8',
      );

      final json = video.toJson();
      expect(json['id'], 'youtube_abc123');
      expect(json['title'], 'Test Video');
      expect(json['thumbnail'], 'https://example.com/thumb.jpg');
      expect(json['duration'], '10:30');
      expect(json['url'], 'https://example.com/stream.m3u8');
    });

    test('copyWith 正確複製', () {
      const video = YoutubeVideo(
        id: 'youtube_abc123',
        title: 'Test Video',
        thumbnail: 'https://example.com/thumb.jpg',
        duration: '10:30',
        url: 'https://example.com/stream.m3u8',
      );

      final copied = video.copyWith(title: 'Updated Title');
      expect(copied.id, 'youtube_abc123');
      expect(copied.title, 'Updated Title');
      expect(copied.thumbnail, 'https://example.com/thumb.jpg');
    });
  });

  group('YoutubeCategory', () {
    test('從 JSON 正確解析', () {
      final json = {
        'id': 'cat_music',
        'name': 'Music',
        'videoCount': 42,
      };

      final category = YoutubeCategory.fromJson(json);
      expect(category.id, 'cat_music');
      expect(category.name, 'Music');
      expect(category.videoCount, 42);
    });

    test('toJson 正確序列化', () {
      const category = YoutubeCategory(
        id: 'cat_music',
        name: 'Music',
        videoCount: 42,
      );

      final json = category.toJson();
      expect(json['id'], 'cat_music');
      expect(json['name'], 'Music');
      expect(json['videoCount'], 42);
    });
  });
}
