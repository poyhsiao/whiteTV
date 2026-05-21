import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';

void main() {
  group('PlayHistory', () {
    test('fromJson creates correct model', () {
      final json = {
        'key': 'history_123',
        'videoId': 'video_456',
        'title': 'Test Video',
        'posterUrl': 'https://example.com/poster.jpg',
        'sourceName': 'Test Source',
        'currentEpisode': 5,
        'totalEpisodes': 10,
        'playTime': 1800,
        'totalTime': 3600,
        'saveTime': DateTime(2024, 1, 15, 10, 30).toIso8601String(),
        'type': 'series',
      };

      final history = PlayHistory.fromJson(json);

      expect(history.key, 'history_123');
      expect(history.videoId, 'video_456');
      expect(history.title, 'Test Video');
      expect(history.posterUrl, 'https://example.com/poster.jpg');
      expect(history.sourceName, 'Test Source');
      expect(history.currentEpisode, 5);
      expect(history.totalEpisodes, 10);
      expect(history.playTime, 1800);
      expect(history.totalTime, 3600);
      expect(history.type, 'series');
      expect(history.pendingDelete, false);
    });

    test('toJson converts correctly', () {
      final history = PlayHistory(
        key: 'history_123',
        videoId: 'video_456',
        title: 'Test Video',
        posterUrl: 'https://example.com/poster.jpg',
        sourceName: 'Test Source',
        currentEpisode: 5,
        totalEpisodes: 10,
        playTime: 1800,
        totalTime: 3600,
        saveTime: DateTime(2024, 1, 15, 10, 30),
        type: 'series',
      );

      final json = history.toJson();

      expect(json['key'], 'history_123');
      expect(json['videoId'], 'video_456');
      expect(json['title'], 'Test Video');
      expect(json['posterUrl'], 'https://example.com/poster.jpg');
      expect(json['sourceName'], 'Test Source');
      expect(json['currentEpisode'], 5);
      expect(json['totalEpisodes'], 10);
      expect(json['playTime'], 1800);
      expect(json['totalTime'], 3600);
      expect(json['type'], 'series');
      expect(json['pendingDelete'], false);
    });

    test('progressPercent returns 50% when playTime=1800, totalTime=3600', () {
      final history = PlayHistory(
        key: 'history_123',
        videoId: 'video_456',
        title: 'Test Video',
        posterUrl: null,
        sourceName: 'Test Source',
        playTime: 1800,
        totalTime: 3600,
        saveTime: DateTime(2024, 1, 15, 10, 30),
        type: 'movie',
      );

      expect(history.progressPercent, 50.0);
    });

    test('progressPercent returns 0 when totalTime=0', () {
      final history = PlayHistory(
        key: 'history_123',
        videoId: 'video_456',
        title: 'Test Video',
        posterUrl: null,
        sourceName: 'Test Source',
        playTime: 0,
        totalTime: 0,
        saveTime: DateTime(2024, 1, 15, 10, 30),
        type: 'movie',
      );

      expect(history.progressPercent, 0.0);
    });

    test('progressPercent clamps to 100 when playTime exceeds totalTime', () {
      final history = PlayHistory(
        key: 'history_123',
        videoId: 'video_456',
        title: 'Test Video',
        posterUrl: null,
        sourceName: 'Test Source',
        playTime: 4000,
        totalTime: 3600,
        saveTime: DateTime(2024, 1, 15, 10, 30),
        type: 'movie',
      );

      expect(history.progressPercent, 100.0);
    });

    test('copyWith creates new instance with updated values', () {
      final history = PlayHistory(
        key: 'history_123',
        videoId: 'video_456',
        title: 'Test Video',
        posterUrl: null,
        sourceName: 'Test Source',
        playTime: 1800,
        totalTime: 3600,
        saveTime: DateTime(2024, 1, 15, 10, 30),
        type: 'movie',
      );

      final updated = history.copyWith(playTime: 2700);

      expect(updated.key, 'history_123');
      expect(updated.playTime, 2700);
      expect(updated.totalTime, 3600);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'key': 'history_123',
        'videoId': 'video_456',
        'title': 'Test Video',
        'sourceName': 'Test Source',
        'playTime': 1800,
        'totalTime': 3600,
        'saveTime': DateTime(2024, 1, 15, 10, 30).toIso8601String(),
        'type': 'movie',
      };

      final history = PlayHistory.fromJson(json);

      expect(history.key, 'history_123');
      expect(history.posterUrl, null);
      expect(history.currentEpisode, null);
      expect(history.totalEpisodes, null);
      expect(history.pendingDelete, false);
    });
  });
}