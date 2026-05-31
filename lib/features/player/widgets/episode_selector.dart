import 'package:flutter/material.dart';
import 'package:white_tv/core/theme/colors.dart';

/// Episode selector widget with tap-to-open dialog showing GridView of episodes
class EpisodeSelector extends StatelessWidget {
  final int currentEpisode;
  final int totalEpisodes;
  final ValueChanged<int>? onEpisodeSelected;

  const EpisodeSelector({
    super.key,
    required this.currentEpisode,
    required this.totalEpisodes,
    this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _EpisodeListDialog(
            currentEpisode: currentEpisode,
            totalEpisodes: totalEpisodes,
            onEpisodeSelected: (episode) {
              onEpisodeSelected?.call(episode);
              Navigator.of(context).pop();
            },
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: Text(
        '第 $currentEpisode 集',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Dialog showing GridView of episodes for selection
class _EpisodeListDialog extends StatelessWidget {
  final int currentEpisode;
  final int totalEpisodes;
  final ValueChanged<int>? onEpisodeSelected;

  const _EpisodeListDialog({
    required this.currentEpisode,
    required this.totalEpisodes,
    this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('選擇集數', style: TextStyle(color: AppColors.textPrimary)),
      backgroundColor: AppColors.cardBackground,
      content: SizedBox(
        width: 400,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalEpisodes,
          itemBuilder: (context, index) {
            final episode = index + 1;
            final isCurrentEpisode = episode == currentEpisode;

            return InkWell(
              onTap: () => onEpisodeSelected?.call(episode),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentEpisode
                      ? AppColors.accent
                      : AppColors.cardBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrentEpisode
                        ? AppColors.accent
                        : AppColors.glassBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$episode',
                  style: TextStyle(
                    color: isCurrentEpisode
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: isCurrentEpisode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
