import 'package:white_tv/features/history/models/play_history.dart';

/// Groups for time-based history display (UI_UX.md §6.1)
enum HistoryGroup { today, yesterday, older }

class HistoryState {
  final List<PlayHistory> records;
  final bool isLoading;
  final String? error;
  final bool isSyncing;

  const HistoryState({
    this.records = const [],
    this.isLoading = false,
    this.error,
    this.isSyncing = false,
  });

  HistoryState copyWith({
    List<PlayHistory>? records,
    bool? isLoading,
    String? error,
    bool? isSyncing,
    bool clearError = false,
  }) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  /// Groups records by time: today / yesterday / older
  Map<HistoryGroup, List<PlayHistory>> get groupedByTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayRecords = <PlayHistory>[];
    final yesterdayRecords = <PlayHistory>[];
    final olderRecords = <PlayHistory>[];

    for (final r in records) {
      final t = r.lastWatched ?? r.saveTime;
      final recordDate = DateTime(t.year, t.month, t.day);
      if (recordDate == today) {
        todayRecords.add(r);
      } else if (recordDate == yesterday) {
        yesterdayRecords.add(r);
      } else {
        olderRecords.add(r);
      }
    }

    return {
      HistoryGroup.today: todayRecords,
      HistoryGroup.yesterday: yesterdayRecords,
      HistoryGroup.older: olderRecords,
    };
  }

  bool get hasAnyHistory => records.isNotEmpty;
}
