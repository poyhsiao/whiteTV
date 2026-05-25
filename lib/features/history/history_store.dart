import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/history/history_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';

/// StateNotifier for managing play history state.
///
/// Provides methods to:
/// - [loadHistory] - Fetch all history records from storage
/// - [addRecord] - Add a new play history record
/// - [deleteRecord] - Delete a record by its key
/// - [syncFromRemote] - Sync records from remote storage
class HistoryStore extends StateNotifier<HistoryState> {
  final HistoryService _historyService;

  HistoryStore(this._historyService) : super(const HistoryState());

  /// Loads history records from the service and updates state.
  /// Sets [isLoading] during the fetch and [error] on failure.
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final records = await _historyService.getHistory();
      state = state.copyWith(records: records, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Adds a new play history record via the service and refreshes the list.
  Future<void> addRecord(PlayHistory record) async {
    try {
      await _historyService.addRecord(record);
      await loadHistory();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Deletes a record by its key via the service and updates state.
  Future<void> deleteRecord(String key) async {
    try {
      await _historyService.deleteRecord(key);
      state = state.copyWith(
        records: state.records.where((r) => r.key != key).toList(),
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Returns records with progress > 5% for "Continue Watching" feature.
  List<PlayHistory> get continueWatchRecords {
    return state.records.where((record) {
      final progress = record.progressPercent;
      return progress > 5.0 && progress < 100.0;
    }).toList()
      ..sort((a, b) => (b.lastWatched ?? b.saveTime)
          .compareTo(a.lastWatched ?? a.saveTime));
  }

  /// Syncs pending records to remote when network is restored.
  Future<void> syncPendingRecords() async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      await _historyService.syncPendingRecords();
      state = state.copyWith(isSyncing: false);
    } on Exception catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  /// Syncs records from remote storage.
  /// Sets [isSyncing] during the sync operation.
  Future<void> syncFromRemote() async {
    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      await _historyService.syncFromRemote();
      state = state.copyWith(isSyncing: false);
    } on Exception catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }
}

/// Provider for HistoryStore that auto-disposes when no longer needed.
final historyStoreProvider =
    StateNotifierProvider.autoDispose<HistoryStore, HistoryState>((ref) {
      throw UnimplementedError(
        'historyStoreProvider must be overridden with a HistoryService instance',
      );
    });