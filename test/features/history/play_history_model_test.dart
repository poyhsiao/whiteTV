import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';

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
  });
}