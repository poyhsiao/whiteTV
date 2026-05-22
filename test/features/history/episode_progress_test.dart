import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/episode_progress.dart';

void main() {
  group('EpisodeProgress', () {
    group('progressPercent', () {
      test('calculates 50% progress correctly', () {
        final progress = EpisodeProgress(
          episodeNumber: 1,
          playTime: 500,
          totalTime: 1000,
        );
        expect(progress.progressPercent, 50.0);
      });

      test('calculates 100% when fully watched', () {
        final progress = EpisodeProgress(
          episodeNumber: 1,
          playTime: 1000,
          totalTime: 1000,
        );
        expect(progress.progressPercent, 100.0);
      });

      test('returns 0 when totalTime is zero', () {
        final progress = EpisodeProgress(
          episodeNumber: 1,
          playTime: 0,
          totalTime: 0,
        );
        expect(progress.progressPercent, 0.0);
      });

      test('clamps to 100 when playTime exceeds totalTime', () {
        final progress = EpisodeProgress(
          episodeNumber: 1,
          playTime: 1500,
          totalTime: 1000,
        );
        expect(progress.progressPercent, 100.0);
      });
    });

    group('fromJson', () {
      test('parses JSON correctly', () {
        final json = {
          'episodeNumber': 3,
          'playTime': 720,
          'totalTime': 1800,
        };
        final progress = EpisodeProgress.fromJson(json);
        expect(progress.episodeNumber, 3);
        expect(progress.playTime, 720);
        expect(progress.totalTime, 1800);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        const progress = EpisodeProgress(
          episodeNumber: 2,
          playTime: 300,
          totalTime: 1200,
        );
        final json = progress.toJson();
        expect(json['episodeNumber'], 2);
        expect(json['playTime'], 300);
        expect(json['totalTime'], 1200);
      });

      test('round-trip: fromJson then toJson preserves data', () {
        const original = EpisodeProgress(
          episodeNumber: 5,
          playTime: 900,
          totalTime: 3600,
        );
        final json = original.toJson();
        final restored = EpisodeProgress.fromJson(json);
        expect(restored.episodeNumber, original.episodeNumber);
        expect(restored.playTime, original.playTime);
        expect(restored.totalTime, original.totalTime);
        expect(restored.progressPercent, original.progressPercent);
      });
    });
  });
}