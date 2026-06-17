import 'dart:math';

import 'package:flutter/material.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';

/// 最近觀看 section widget for home screen
/// Displays horizontal scrollable list of recent watch records with progress
class RecentWatchSection extends StatelessWidget {
  const RecentWatchSection({
    super.key,
    required this.records,
    required this.onTap,
    this.showProgress = false,
  });

  final List<PlayHistory> records;
  final Function(PlayHistory) onTap;
  /// Show playback progress bar on each poster card
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text('最近觀看', style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: min(records.length, 10),
            itemBuilder: (context, index) {
              final record = records[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PosterCard(
                  title: record.title,
                  posterUrl: record.posterUrl,
                  onTap: () => onTap(record),
                  width: 120,
                  height: 160,
                  showProgress: showProgress,
                  progressPercent: record.progressPercent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
