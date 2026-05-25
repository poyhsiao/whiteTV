import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/utils/time_grouper.dart';

void main() {
  PlayHistory createPlayHistory({
    DateTime? lastWatched,
    DateTime? saveTime,
  }) {
    final now = DateTime.now();
    return PlayHistory(
      key: 'key_${now.millisecondsSinceEpoch}',
      videoId: 'videoId',
      title: 'title',
      sourceName: 'sourceName',
      playTime: 0,
      totalTime: 100,
      lastWatched: lastWatched,
      saveTime: saveTime ?? now,
      type: 'movie',
      mediaType: MediaType.movie,
    );
  }

  group('TimeGrouper', () {
    test('groups records into today, yesterday, and older', () {
      final now = DateTime.now();
      final records = [
        createPlayHistory(lastWatched: now),
        createPlayHistory(lastWatched: now.subtract(const Duration(days: 1))),
        createPlayHistory(lastWatched: now.subtract(const Duration(days: 7))),
      ];

      final groups = TimeGrouper.groupByTime(records);

      expect(groups['今天']!.length, 1);
      expect(groups['昨天']!.length, 1);
      expect(groups['更早']!.length, 1);
    });

    test('uses saveTime when lastWatched is null', () {
      final now = DateTime.now();
      final records = [
        createPlayHistory(lastWatched: null, saveTime: now),
        createPlayHistory(lastWatched: null, saveTime: now.subtract(const Duration(days: 1))),
        createPlayHistory(lastWatched: null, saveTime: now.subtract(const Duration(days: 7))),
      ];

      final groups = TimeGrouper.groupByTime(records);

      expect(groups['今天']!.length, 1);
      expect(groups['昨天']!.length, 1);
      expect(groups['更早']!.length, 1);
    });

    test('returns empty lists when no records provided', () {
      final groups = TimeGrouper.groupByTime([]);

      expect(groups['今天']!.length, 0);
      expect(groups['昨天']!.length, 0);
      expect(groups['更早']!.length, 0);
    });
  });
}
