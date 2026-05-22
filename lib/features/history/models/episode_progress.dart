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