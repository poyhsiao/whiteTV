import 'package:flutter/material.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';

class DownloadsGrid extends StatelessWidget {
  const DownloadsGrid({
    super.key,
    required this.downloads,
    required this.onDelete,
    required this.isTvLayout,
  });

  final List<PlayHistory> downloads;
  final void Function(String videoId, String title) onDelete;
  final bool isTvLayout;

  @override
  Widget build(BuildContext context) {
    if (isTvLayout) {
      return _buildTvLayout(context);
    }
    return _buildMobileLayout(context);
  }

  Widget _buildTvLayout(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return _DownloadCard(
          download: download,
          onDelete: () => onDelete(download.videoId, download.title),
          isLarge: true,
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return _DownloadListTile(
          download: download,
          onDelete: () => onDelete(download.videoId, download.title),
        );
      },
    );
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({
    required this.download,
    required this.onDelete,
    required this.isLarge,
  });

  final PlayHistory download;
  final VoidCallback onDelete;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: PosterCard(
              posterUrl: download.posterUrl,
              title: download.title,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      download.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: onDelete,
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '已下載',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadListTile extends StatelessWidget {
  const _DownloadListTile({
    required this.download,
    required this.onDelete,
  });

  final PlayHistory download;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 80,
        height: 45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: PosterCard(
            posterUrl: download.posterUrl,
            title: download.title,
          ),
        ),
      ),
      title: Text(
        download.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        download.sourceName,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
