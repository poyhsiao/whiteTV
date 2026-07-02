import 'package:white_tv/features/history/models/play_history.dart';

class DownloadsState {
  final List<PlayHistory> downloads;
  final bool isLoading;
  final String? error;
  final Map<String, double> downloadProgress;
  final Set<String> activeDownloadIds;

  const DownloadsState({
    this.downloads = const [],
    this.isLoading = false,
    this.error,
    this.downloadProgress = const {},
    this.activeDownloadIds = const {},
  });

  bool isDownloading(String videoId) => activeDownloadIds.contains(videoId);

  DownloadsState copyWith({
    List<PlayHistory>? downloads,
    bool? isLoading,
    String? error,
    Map<String, double>? downloadProgress,
    Set<String>? activeDownloadIds,
    bool clearError = false,
  }) {
    return DownloadsState(
      downloads: downloads ?? this.downloads,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      downloadProgress: downloadProgress ?? this.downloadProgress,
      activeDownloadIds: activeDownloadIds ?? this.activeDownloadIds,
    );
  }
}
