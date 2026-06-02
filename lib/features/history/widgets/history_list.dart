import 'package:flutter/material.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/utils/time_grouper.dart';
import 'package:white_tv/features/history/widgets/history_tile.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
  });

  final List<PlayHistory> records;
  final void Function(PlayHistory) onTap;
  final void Function(PlayHistory) onDelete;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: '還沒有觀看記錄',
      );
    }

    final groupedRecords = TimeGrouper.groupByTime(records);

    return ListView.builder(
      itemCount: _calculateItemCount(groupedRecords),
      itemBuilder: (context, index) {
        return _buildItem(context, index, groupedRecords);
      },
    );
  }

  int _calculateItemCount(Map<String, List<PlayHistory>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      if (entry.value.isNotEmpty) {
        count += 1 + entry.value.length;
      }
    }
    return count;
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Map<String, List<PlayHistory>> grouped,
  ) {
    int currentIndex = 0;

    for (final entry in grouped.entries) {
      if (entry.value.isEmpty) continue;

      if (index == currentIndex) {
        return _buildSectionHeader(entry.key);
      }
      currentIndex++;

      if (index < currentIndex + entry.value.length) {
        final recordIndex = index - currentIndex;
        final record = entry.value[recordIndex];
        return HistoryTile(
          history: record,
          onTap: () => onTap(record),
          onDelete: () => onDelete(record),
        );
      }
      currentIndex += entry.value.length;
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
}
