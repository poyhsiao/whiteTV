import 'package:flutter/material.dart';
import 'package:white_tv/core/theme/colors.dart';

/// Episode navigation widget with previous/next episode buttons
class EpisodeNavigation extends StatelessWidget {
  final int currentEpisode;
  final int totalEpisodes;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const EpisodeNavigation({
    super.key,
    required this.currentEpisode,
    required this.totalEpisodes,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, color: AppColors.textPrimary),
            onPressed: currentEpisode > 1 ? onPrevious : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$currentEpisode/$totalEpisodes',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: AppColors.textPrimary),
            onPressed: currentEpisode < totalEpisodes ? onNext : null,
          ),
        ],
      ),
    );
  }
}
