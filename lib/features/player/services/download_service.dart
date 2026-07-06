import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';

class DownloadService {
  final Dio _dio;
  final HistoryLocalService _localService;

  DownloadService(this._dio, this._localService);

  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${dir.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final filePath = '${downloadsDir.path}/$videoId.mp4';
    DioException? lastError;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await _dio.download(
          url,
          filePath,
          onReceiveProgress: onProgress,
        );

        // Update history record to mark as downloaded
        final records = await _localService.getAll();
        final recordIndex = records.indexWhere((r) => r.videoId == videoId);

        if (recordIndex >= 0) {
          final record = records[recordIndex];
          final updated = record.copyWith(
            isDownloaded: true,
            localPath: filePath,
            saveTime: DateTime.now(),
          );
          await _localService.save(updated);
        }

        return filePath;
      } on DioException catch (e) {
        lastError = e;
        // Only retry on connection errors, not on 4xx client errors
        if (e.type != DioExceptionType.connectionError &&
            e.type != DioExceptionType.connectionTimeout &&
            e.type != DioExceptionType.receiveTimeout) {
          break;
        }
      } on FileSystemException {
        rethrow;
      }
    }

    // All retries exhausted — rethrow as DioException for store to handle
    if (lastError != null) throw lastError;
    return null;
  }

  Future<bool> isDownloaded(String videoId) async {
    final records = await _localService.getAll();
    return records.any((r) => r.videoId == videoId && r.isDownloaded);
  }

  Future<String?> getLocalPath(String videoId) async {
    final records = await _localService.getAll();
    final record = records.where((r) => r.videoId == videoId && r.isDownloaded).firstOrNull;
    return record?.localPath;
  }

  Future<bool> deleteDownload(String videoId) async {
    try {
      final localPath = await getLocalPath(videoId);
      if (localPath == null) return false;

      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }

      // Update history record to remove download flag
      final records = await _localService.getAll();
      final recordIndex = records.indexWhere((r) => r.videoId == videoId);

      if (recordIndex >= 0) {
        final record = records[recordIndex];
        final updated = record.copyWith(
          isDownloaded: false,
          localPath: null,
          saveTime: DateTime.now(),
        );
        await _localService.save(updated);
      }

      return true;
    } on FileSystemException {
      return false;
    }
  }
}