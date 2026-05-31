import 'package:flutter/material.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/theme/colors.dart';

/// 來源切換小組件
/// 顯示為 OutlinedButton，點擊後彈出對話框選擇視頻來源
///
/// 用於 TV 控制欄，展示來源名稱，點擊後顯示所有來源的列表

class SourceSwitcher extends StatelessWidget {
  const SourceSwitcher({
    super.key,
    required this.sources,
    required this.selectedSourceId,
    required this.onSourceSelected,
    this.isAutoSelected = false,
  });

  /// 視頻來源列表
  final List<VideoSource> sources;

  /// 當前選中的來源 ID
  final String? selectedSourceId;

  /// 來源選擇回調
  final ValueChanged<VideoSource> onSourceSelected;

  /// 是否為自動選擇的來源
  final bool isAutoSelected;

  @override
  Widget build(BuildContext context) {
    final selectedSource = sources.firstWhere(
      (s) => s.id == selectedSourceId,
      orElse: () => sources.isNotEmpty
          ? sources.first
          : const VideoSource(id: '', name: '無來源', url: '', latency: 0),
    );

    return OutlinedButton.icon(
      onPressed: sources.isEmpty ? null : () => _showSourceDialog(context),
      icon: const Icon(Icons.source, size: 18),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedSource.name),
            if (isAutoSelected) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '[自動]',
                  style: TextStyle(fontSize: 10, color: AppColors.accent),
                ),
              ),
            ],
          ],
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.glassBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '選擇來源',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sources.length,
            itemBuilder: (context, index) {
              final source = sources[index];
              final isSelected = source.id == selectedSourceId;

              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
                title: Text(
                  source.name,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  '${source.latency}ms',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  onSourceSelected(source);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
