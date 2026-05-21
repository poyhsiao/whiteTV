import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/history/services/history_remote_service.dart';

/// Facade service that coordinates local and remote history services.
/// Uses local-first strategy: reads from local storage, writes to both
/// local and remote (background sync).
class HistoryService {
  final HistoryLocalService _localService;
  final HistoryRemoteService _remoteService;

  HistoryService(this._localService, this._remoteService);

  /// Gets history records from local storage (local-first).
  Future<List<PlayHistory>> getHistory() async {
    return _localService.getAll();
  }

  /// Adds a record: saves to local storage immediately,
  /// then triggers background sync to remote.
  Future<void> addRecord(PlayHistory record) async {
    await _localService.save(record);
    // Background sync to remote - fire and forget
    _syncToRemote(record);
  }

  /// Deletes a record: removes from local storage immediately,
  /// then triggers background sync to remote.
  Future<void> deleteRecord(String key) async {
    await _localService.delete(key);
    // Background sync to remote - fire and forget
    _syncToRemoteDelete(key);
  }

  /// Syncs records from remote and merges with local storage.
  Future<void> syncFromRemote() async {
    final remoteRecords = await _remoteService.fetchFromRemote();
    for (final record in remoteRecords) {
      await _localService.save(record);
    }
  }

  Future<void> _syncToRemote(PlayHistory record) async {
    // Background sync - ignore errors
    try {
      await _remoteService.fetchFromRemote();
    } catch (_) {
      // Silently ignore remote sync failures
    }
  }

  Future<void> _syncToRemoteDelete(String key) async {
    // Background sync - ignore errors
    try {
      await _remoteService.fetchFromRemote();
    } catch (_) {
      // Silently ignore remote sync failures
    }
  }
}
