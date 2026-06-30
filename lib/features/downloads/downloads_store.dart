import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class DownloadsStore extends StateNotifier<DownloadsState> {
  final DownloadService _downloadService;
  final HistoryLocalService _historyService;

  DownloadsStore(this._downloadService, this._historyService)
      : super(const DownloadsState());

  Future<void> loadDownloads() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final records = await _historyService.getAll();
      final downloads = records.where((r) => r.isDownloaded).toList();
      state = state.copyWith(downloads: downloads, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteDownload(String videoId) async {
    try {
      await _downloadService.deleteDownload(videoId);
      state = state.copyWith(
        downloads: state.downloads.where((d) => d.videoId != videoId).toList(),
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void updateProgress(String videoId, double progress) {
    final updatedProgress = Map<String, double>.from(state.downloadProgress);
    updatedProgress[videoId] = progress;
    state = state.copyWith(downloadProgress: updatedProgress);
  }
}

final downloadsStoreProvider =
    StateNotifierProvider.autoDispose<DownloadsStore, DownloadsState>((ref) {
  throw UnimplementedError(
    'downloadsStoreProvider must be overridden with DownloadService and HistoryLocalService instances',
  );
});
