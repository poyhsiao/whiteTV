import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/history/models/play_history.dart';

/// Remote service for fetching play history from LunaTV API
class HistoryRemoteService {
  final ApiClient _apiClient;

  HistoryRemoteService(this._apiClient);

  /// Fetches play history from remote API
  Future<List<PlayHistory>> fetchFromRemote() async {
    final response = await _apiClient.getUserStats();
    final stats = response['stats'] as Map<String, dynamic>?;
    if (stats == null) return [];

    final continueWatch = stats['continueWatch'] as List<dynamic>?;
    if (continueWatch == null) return [];

    return continueWatch
        .map((json) => _parseContinueWatchItem(json as Map<String, dynamic>))
        .toList();
  }

  PlayHistory _parseContinueWatchItem(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final sourceName = json['source_name'] as String;
    final year = json['year'] as String? ?? '';

    return PlayHistory(
      key: '${sourceName}_${title}_$year',
      videoId: '', // Remote data doesn't have videoId
      title: title,
      posterUrl: json['cover'] as String?,
      sourceName: sourceName,
      currentEpisode: json['index'] as int?,
      totalEpisodes: json['total_episodes'] as int?,
      playTime: json['play_time'] as int? ?? 0,
      totalTime: json['total_time'] as int? ?? 0,
      saveTime: DateTime.fromMillisecondsSinceEpoch(
        json['save_time'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      type: 'continue_watch',
    );
  }
}
