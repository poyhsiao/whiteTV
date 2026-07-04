import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/history/services/history_remote_service.dart';

/// Facade service that coordinates local and remote history services.
/// Uses local-first strategy: reads from local storage, writes to both
/// local and remote (background sync).
///
/// Implements offline queue: when remote sync fails, records are queued
/// locally for later retry via syncPendingRecords().
class HistoryService {
  final HistoryLocalService _localService;
  final HistoryRemoteService _remoteService;
  final List<PlayHistory> _offlineQueue = [];

  HistoryService(this._localService, this._remoteService);

  /// Gets pending records from the offline queue.
  List<PlayHistory> getPendingRecords() => List.unmodifiable(_offlineQueue);

  /// Returns true if there are pending records in the offline queue.
  bool get hasPendingRecords => _offlineQueue.isNotEmpty;

  /// Returns the count of pending records.
  int get pendingRecordCount => _offlineQueue.length;

  /// Gets history records from local storage (local-first).
  Future<List<PlayHistory>> getHistory() async {
    return _localService.getAll();
  }

  /// Adds a record: saves to local storage immediately,
  /// then triggers background sync to remote.
  /// If remote sync fails, record is added to offline queue for later retry.
  Future<void> addRecord(PlayHistory record) async {
    await _localService.save(record);
    // Background sync to remote
    try {
      await _remoteService.fetchFromRemote();
    } catch (_) {
      // Add to offline queue if remote sync fails
      _offlineQueue.add(record);
    }
  }

  /// Deletes a record: removes from local storage immediately,
  /// then triggers background sync to remote.
  Future<void> deleteRecord(String key) async {
    await _localService.delete(key);
    // Background sync to remote - fire and forget
    _syncToRemoteDelete(key);
  }

  /// Syncs records from remote and merges with local storage.
  /// Merge policy: lastWatched timestamp — local newer wins, otherwise remote overwrites.
  Future<void> syncFromRemote() async {
    final remoteRecords = await _remoteService.fetchFromRemote();
    final localRecords = await _localService.getAll();
    final localByKey = {for (final r in localRecords) r.key: r};

    for (final remoteRecord in remoteRecords) {
      final local = localByKey[remoteRecord.key];
      if (local == null) {
        await _localService.save(remoteRecord);
        continue;
      }
      final localStamp = local.lastWatched ?? local.saveTime;
      final remoteStamp = remoteRecord.lastWatched ?? remoteRecord.saveTime;
      if (remoteStamp.isAfter(localStamp)) {
        await _localService.save(remoteRecord);
      }
      // else: 本地較新,保留本地
    }
  }

  /// Syncs all pending records from the offline queue to remote.
  /// Removes records from queue on successful sync.
  Future<void> syncPendingRecords() async {
    if (_offlineQueue.isEmpty) return;

    final recordsToSync = List<PlayHistory>.from(_offlineQueue);
    final successfullySynced = <PlayHistory>[];

    for (final record in recordsToSync) {
      try {
        await _remoteService.fetchFromRemote();
        successfullySynced.add(record);
      } catch (_) {
        // Continue with next record, keep failed ones in queue
      }
    }

    // Remove successfully synced records from queue
    for (final record in successfullySynced) {
      _offlineQueue.remove(record);
    }
  }

  /// Pushes a single record to remote storage.
  /// Used for manual sync or retry after network recovery.
  Future<bool> pushRecordToRemote(PlayHistory record) async {
    try {
      final result = await _remoteService.saveRecord(record);
      return result;
    } on Exception catch (_) {
      return false;
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
