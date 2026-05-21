import 'package:white_tv/features/history/models/play_history.dart';

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
}
