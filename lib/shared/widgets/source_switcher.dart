import 'package:flutter/material.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/theme/colors.dart';

/// 來源切換小組件
/// 顯示視頻來源列表，支持選擇、切換和屏蔽功能
///
/// 參照: AppColors 中的 sourceAvailable, sourceUnavailable, sourceTesting

class SourceSwitcher extends StatelessWidget {
  const SourceSwitcher({
    super.key,
    required this.sources,
    required this.selectedSourceId,
    required this.onSourceSelected,
    this.onSourceBlocked,
    this.currentSourceLabel,
  });

  /// 視頻來源列表
  final List<VideoSource> sources;

  /// 當前選中的來源 ID
  final String? selectedSourceId;

  /// 來源選擇回調
  final ValueChanged<VideoSource> onSourceSelected;

  /// 來源屏蔽回調（可選）
  final ValueChanged<String>? onSourceBlocked;

  /// 當前來源標籤（可選）
  final String? currentSourceLabel;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentSourceLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              currentSourceLabel!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sources.length,
            itemBuilder: (context, index) {
              final source = sources[index];
              final isSelected = source.id == selectedSourceId;
              final isAvailable = source.isAvailable;

              return ListTile(
                leading: _buildStatusIndicator(isSelected, isAvailable),
                title: Text(
                  source.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${source.latency}ms',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.block,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onSourceBlocked != null
                      ? () => onSourceBlocked!(source.id)
                      : null,
                  tooltip: '屏蔽此來源',
                ),
                onTap: isAvailable ? () => onSourceSelected(source) : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(bool isSelected, bool isAvailable) {
    Color color;
    IconData icon;

    if (!isAvailable) {
      color = AppColors.sourceUnavailable;
      icon = Icons.error_outline;
    } else if (isSelected) {
      color = AppColors.accent;
      icon = Icons.check_circle;
    } else {
      color = AppColors.sourceAvailable;
      icon = Icons.circle_outlined;
    }

    return Icon(icon, color: color, size: 20);
  }
}
