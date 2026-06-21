import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/episode_progress.dart';
import 'package:white_tv/features/history/models/media_type.dart';

void main() {
  group('History BDD', () {
    test('EpisodeProgress calculates percentage correctly', () {
      // Given 50% progress
      final progress = EpisodeProgress(
        episodeNumber: 1,
        playTime: 3000,
        totalTime: 6000,
      );
      
      // Then 應該顯示 "50%"
      expect(progress.progressPercent, equals(50.0));
    });

    test('EpisodeProgress handles zero total', () {
      final progress = EpisodeProgress(
        episodeNumber: 1,
        playTime: 0,
        totalTime: 0,
      );
      
      expect(progress.progressPercent, equals(0.0));
    });

    test('MediaType fromString works', () {
      expect(MediaType.fromString('movie'), equals(MediaType.movie));
      expect(MediaType.fromString('series'), equals(MediaType.series));
    });
  });
}
