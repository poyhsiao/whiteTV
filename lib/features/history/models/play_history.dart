import 'package:white_tv/features/history/models/episode_progress.dart';
import 'package:white_tv/features/history/models/media_type.dart';

class PlayHistory {
  final String key;
  final String videoId;
  final String title;
  final String? posterUrl;
  final String sourceName;
  final int? currentEpisode;
  final int? totalEpisodes;
  final int playTime;
  final int totalTime;
  final Duration lastPosition;
  final int watchedTime;
  final DateTime? lastWatched;
  final DateTime saveTime;
  final String type;
  final MediaType mediaType;
  final bool pendingDelete;
  final List<EpisodeProgress> episodeProgress;
  final bool isDownloaded;
  final String? localPath;

  const PlayHistory({
    required this.key,
    required this.videoId,
    required this.title,
    this.posterUrl,
    required this.sourceName,
    this.currentEpisode,
    this.totalEpisodes,
    required this.playTime,
    required this.totalTime,
    this.lastPosition = Duration.zero,
    this.watchedTime = 0,
    this.lastWatched,
    required this.saveTime,
    required this.type,
    this.mediaType = MediaType.movie,
    this.pendingDelete = false,
    this.episodeProgress = const [],
    this.isDownloaded = false,
    this.localPath,
  });

  double get progressPercent {
    if (totalTime == 0) return 0.0;
    return (playTime / totalTime * 100).clamp(0.0, 100.0);
  }

  factory PlayHistory.fromJson(Map<String, dynamic> json) {
    return PlayHistory(
      key: json['key'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String?,
      sourceName: json['sourceName'] as String,
      currentEpisode: json['currentEpisode'] as int?,
      totalEpisodes: json['totalEpisodes'] as int?,
      playTime: json['playTime'] as int,
      totalTime: json['totalTime'] as int,
      lastPosition: Duration(seconds: json['lastPosition'] as int? ?? 0),
      watchedTime: json['watchedTime'] as int? ?? 0,
      lastWatched: json['lastWatched'] != null
          ? DateTime.parse(json['lastWatched'] as String)
          : null,
      saveTime: DateTime.parse(json['saveTime'] as String),
      type: json['type'] as String,
      mediaType: MediaType.fromString(json['mediaType'] as String? ?? 'movie'),
      pendingDelete: json['pendingDelete'] as bool? ?? false,
      episodeProgress: (json['episodeProgress'] as List<dynamic>?)
              ?.map((e) => EpisodeProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'videoId': videoId,
      'title': title,
      'posterUrl': posterUrl,
      'sourceName': sourceName,
      'currentEpisode': currentEpisode,
      'totalEpisodes': totalEpisodes,
      'playTime': playTime,
      'totalTime': totalTime,
      'lastPosition': lastPosition.inSeconds,
      'watchedTime': watchedTime,
      'lastWatched': lastWatched?.toIso8601String(),
      'saveTime': saveTime.toIso8601String(),
      'type': type,
      'mediaType': mediaType.value,
      'pendingDelete': pendingDelete,
      'episodeProgress': episodeProgress.map((e) => e.toJson()).toList(),
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }

  PlayHistory copyWith({
    String? key,
    String? videoId,
    String? title,
    String? posterUrl,
    String? sourceName,
    int? currentEpisode,
    int? totalEpisodes,
    int? playTime,
    int? totalTime,
    Duration? lastPosition,
    int? watchedTime,
    DateTime? lastWatched,
    DateTime? saveTime,
    String? type,
    bool? pendingDelete,
    List<EpisodeProgress>? episodeProgress,
    bool? isDownloaded,
    String? localPath,
  }) {
    return PlayHistory(
      key: key ?? this.key,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      sourceName: sourceName ?? this.sourceName,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      playTime: playTime ?? this.playTime,
      totalTime: totalTime ?? this.totalTime,
      lastPosition: lastPosition ?? this.lastPosition,
      watchedTime: watchedTime ?? this.watchedTime,
      lastWatched: lastWatched ?? this.lastWatched,
      saveTime: saveTime ?? this.saveTime,
      type: type ?? this.type,
      pendingDelete: pendingDelete ?? this.pendingDelete,
      episodeProgress: episodeProgress ?? this.episodeProgress,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }
}