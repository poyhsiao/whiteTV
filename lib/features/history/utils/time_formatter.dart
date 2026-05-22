class TimeFormatter {
  static String formatWatchTime(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours >= 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      return '${days}d ${remainingHours}h';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }

  static String formatDuration(Duration duration) {
    return formatWatchTime(duration.inSeconds);
  }
}