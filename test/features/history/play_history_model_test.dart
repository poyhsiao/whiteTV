import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/episode_progress.dart';

void main() {
  group('PlayHistory', () {
    test('copyWith preserves lastPosition', () {
      final original = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        lastPosition: const Duration(seconds: 30),
      );

      final updated = original.copyWith(playTime: 150);
      expect(updated.lastPosition, const Duration(seconds: 30));
    });

    test('lastPosition serializes to JSON', () {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        lastPosition: const Duration(seconds: 45),
      );

      final json = history.toJson();
      expect(json['lastPosition'], 45);
    });

    test('fromJson deserializes lastPosition', () {
      final json = {
        'key': 'key1',
        'videoId': 'video1',
        'title': 'Test',
        'sourceName': 'source',
        'playTime': 100,
        'totalTime': 200,
        'saveTime': '2026-05-22T10:00:00.000',
        'type': 'movie',
        'lastPosition': 60,
      };

      final history = PlayHistory.fromJson(json);
      expect(history.lastPosition, const Duration(seconds: 60));
    });

    test('episodeProgress serializes to JSON', () {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'series',
        episodeProgress: [
          const EpisodeProgress(episodeNumber: 1, playTime: 100, totalTime: 200),
          const EpisodeProgress(episodeNumber: 2, playTime: 50, totalTime: 150),
        ],
      );

      final json = history.toJson();
      expect(json['episodeProgress'], isA<List>());
      expect(json['episodeProgress'].length, 2);
      expect(json['episodeProgress'][0]['episodeNumber'], 1);
      expect(json['episodeProgress'][1]['episodeNumber'], 2);
    });

    test('fromJson deserializes episodeProgress', () {
      final json = {
        'key': 'key1',
        'videoId': 'video1',
        'title': 'Test',
        'sourceName': 'source',
        'playTime': 100,
        'totalTime': 200,
        'saveTime': '2026-05-22T10:00:00.000',
        'type': 'series',
        'episodeProgress': [
          {'episodeNumber': 1, 'playTime': 100, 'totalTime': 200},
          {'episodeNumber': 2, 'playTime': 50, 'totalTime': 150},
        ],
      };

      final history = PlayHistory.fromJson(json);
      expect(history.episodeProgress, hasLength(2));
      expect(history.episodeProgress[0].episodeNumber, 1);
      expect(history.episodeProgress[1].episodeNumber, 2);
    });

    test('isDownloaded serializes to JSON', () {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        isDownloaded: true,
      );

      final json = history.toJson();
      expect(json['isDownloaded'], true);
    });

    test('fromJson deserializes isDownloaded', () {
      final json = {
        'key': 'key1',
        'videoId': 'video1',
        'title': 'Test',
        'sourceName': 'source',
        'playTime': 100,
        'totalTime': 200,
        'saveTime': '2026-05-22T10:00:00.000',
        'type': 'movie',
        'isDownloaded': true,
      };

      final history = PlayHistory.fromJson(json);
      expect(history.isDownloaded, true);
    });

    test('localPath serializes to JSON', () {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        localPath: '/path/to/downloaded/file.mp4',
      );

      final json = history.toJson();
      expect(json['localPath'], '/path/to/downloaded/file.mp4');
    });

    test('fromJson deserializes localPath', () {
      final json = {
        'key': 'key1',
        'videoId': 'video1',
        'title': 'Test',
        'sourceName': 'source',
        'playTime': 100,
        'totalTime': 200,
        'saveTime': '2026-05-22T10:00:00.000',
        'type': 'movie',
        'localPath': '/path/to/downloaded/file.mp4',
      };

      final history = PlayHistory.fromJson(json);
      expect(history.localPath, '/path/to/downloaded/file.mp4');
    });

    test('copyWith preserves episodeProgress', () {
      final original = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'series',
        episodeProgress: [
          const EpisodeProgress(episodeNumber: 1, playTime: 100, totalTime: 200),
        ],
      );

      final updated = original.copyWith(playTime: 150);
      expect(updated.episodeProgress, hasLength(1));
      expect(updated.episodeProgress[0].episodeNumber, 1);
    });

    test('copyWith preserves isDownloaded', () {
      final original = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        isDownloaded: true,
      );

      final updated = original.copyWith(playTime: 150);
      expect(updated.isDownloaded, true);
    });

    test('copyWith preserves localPath', () {
      final original = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        localPath: '/path/to/file.mp4',
      );

      final updated = original.copyWith(playTime: 150);
      expect(updated.localPath, '/path/to/file.mp4');
    });
  });
}