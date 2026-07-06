import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';
import 'package:white_tv/providers/downloads_providers.dart';

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

  Future<void> startDownload({
    required String videoId,
    required String url,
    required String title,
    String? posterUrl,
    String? sourceName,
    MediaType mediaType = MediaType.movie,
    int? episodeIndex,
  }) async {
    if (state.activeDownloadIds.contains(videoId)) return;

    state = state.copyWith(
      activeDownloadIds: {...state.activeDownloadIds, videoId},
      downloadProgress: {...state.downloadProgress, videoId: 0},
      clearError: true,
    );

    try {
      final path = await _downloadService.download(
        videoId: videoId,
        url: url,
        onProgress: (received, total) {
          if (total > 0) {
            updateProgress(videoId, received / total);
          }
        },
      );

      if (path != null) {
        await loadDownloads();
        state = state.copyWith(
          activeDownloadIds: state.activeDownloadIds.toSet()..remove(videoId),
          downloadProgress: Map.from(state.downloadProgress)..remove(videoId),
        );
      } else {
        state = state.copyWith(
          error: '下載失敗',
          activeDownloadIds: state.activeDownloadIds.where((id) => id != videoId).toSet(),
          downloadProgress: Map.from(state.downloadProgress)..remove(videoId),
        );
      }
    } on DioException catch (e) {
      String msg = '下載失敗';
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        msg = '網路連線中斷';
      }
      state = state.copyWith(
        error: msg,
        activeDownloadIds: state.activeDownloadIds.where((id) => id != videoId).toSet(),
        downloadProgress: Map.from(state.downloadProgress)..remove(videoId),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        activeDownloadIds: state.activeDownloadIds.where((id) => id != videoId).toSet(),
        downloadProgress: Map.from(state.downloadProgress)..remove(videoId),
      );
    }
  }
}

final downloadsStoreProvider =
    StateNotifierProvider.autoDispose<DownloadsStore, DownloadsState>((ref) {
  return DownloadsStore(
    ref.read(downloadServiceProvider),
    ref.read(historyLocalServiceProvider),
  );
});
