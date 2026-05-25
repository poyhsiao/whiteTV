import 'package:white_tv/features/history/models/play_history.dart';

class TimeGrouper {
  static Map<String, List<PlayHistory>> groupByTime(List<PlayHistory> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<PlayHistory>>{
      '今天': [],
      '昨天': [],
      '更早': [],
    };

    for (final record in records) {
      final recordDate = record.lastWatched ?? record.saveTime;
      final recordDay = DateTime(recordDate.year, recordDate.month, recordDate.day);

      if (recordDay == today) {
        groups['今天']!.add(record);
      } else if (recordDay == yesterday) {
        groups['昨天']!.add(record);
      } else {
        groups['更早']!.add(record);
      }
    }

    return groups;
  }
}
