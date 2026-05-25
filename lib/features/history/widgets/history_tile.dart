import 'package:flutter/material.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/utils/time_formatter.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.history,
    required this.onTap,
    required this.onDelete,
  });

  final PlayHistory history;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final episodeInfo =
        history.currentEpisode != null &&
            history.totalEpisodes != null
        ? '第 ${history.currentEpisode} 集/共 ${history.totalEpisodes} 集'
        : null;

    return ListTile(
      onTap: onTap,
      onLongPress: onDelete,
      leading: history.posterUrl != null
          ? Image.network(
              history.posterUrl!,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 90,
                color: Colors.grey[300],
                child: const Icon(Icons.movie),
              ),
            )
          : Container(
              width: 60,
              height: 90,
              color: Colors.grey[300],
              child: const Icon(Icons.movie),
            ),
      title: Text(history.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSourceBadge(),
          if (episodeInfo != null) Text(episodeInfo),
          if (history.watchedTime > 0)
            Text('已觀看 ${TimeFormatter.formatWatchTime(history.watchedTime)}'),
        ],
      ),
      trailing: _buildProgressBar(),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: history.progressPercent / 100,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation(Colors.amber),
          ),
          const SizedBox(height: 4),
          Text(
            '${history.progressPercent.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber),
      ),
      child: Text(
        history.sourceName,
        style: const TextStyle(fontSize: 10, color: Colors.amber),
      ),
    );
  }
}
