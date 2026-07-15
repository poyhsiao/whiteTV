class EpisodeProgress {
  final int episodeNumber;
  final int playTime;
  final int totalTime;

  const EpisodeProgress({
    required this.episodeNumber,
    required this.playTime,
    required this.totalTime,
  });

  double get progressPercent {
    if (totalTime == 0) return 0.0;
    return (playTime / totalTime * 100).clamp(0.0, 100.0);
  }

  /// Fraction of progress (0.0 to 1.0)
  double get progressFraction {
    if (totalTime == 0) return 0.0;
    return (playTime / totalTime).clamp(0.0, 1.0);
  }

  /// Whether playback is completed (>= 95% progress)
  bool get isCompleted {
    return progressPercent >= 95.0;
  }

  factory EpisodeProgress.fromJson(Map<String, dynamic> json) {
    return EpisodeProgress(
      episodeNumber: json['episodeNumber'] as int,
      playTime: json['playTime'] as int,
      totalTime: json['totalTime'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'episodeNumber': episodeNumber,
    'playTime': playTime,
    'totalTime': totalTime,
  };
}