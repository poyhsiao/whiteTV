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
    final isTvType = history.type == 'tv';
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
          Text(history.sourceName),
          if (episodeInfo != null) Text(episodeInfo),
          if (history.watchedTime > 0)
            Text('已觀看 ${TimeFormatter.formatWatchTime(history.watchedTime)}'),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${history.progressPercent.toInt()}%'),
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: history.progressPercent / 100,
            ),
          ),
        ],
      ),
    );
  }
}
