import 'package:flutter/material.dart';
import 'package:white_tv/core/theme/colors.dart';

/// Settings panel for player screen with subtitle and audio track options.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, color: AppColors.textPrimary),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const _SettingsDialog(),
        );
      },
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('播放設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle section
          const Text('字幕'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('關閉'),
                selected: false,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('中文'),
                selected: true,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('英文'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Audio track section
          const Text('音軌'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('國語'),
                selected: true,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('粵語'),
                selected: false,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('英語'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('關閉'),
        ),
      ],
    );
  }
}
