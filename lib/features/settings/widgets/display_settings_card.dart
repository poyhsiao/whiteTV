import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_store.dart';

class DisplaySettingsCard extends ConsumerWidget {
  const DisplaySettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHomeBlocksSection(ref, settings)],
      ),
    );
  }

  Widget _buildHomeBlocksSection(WidgetRef ref, SettingsState settings) {
    final homeBlocks = settings.homeBlocks;

    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '首頁區塊',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBlockToggle(
              ref,
              'showRecentWatch',
              '最近觀看',
              homeBlocks['showRecentWatch'] ?? true,
            ),
            _buildBlockToggle(
              ref,
              'showLive',
              '直播',
              homeBlocks['showLive'] ?? true,
            ),
            _buildBlockToggle(
              ref,
              'showCategories',
              '分類',
              homeBlocks['showCategories'] ?? true,
            ),
            _buildBlockToggle(
              ref,
              'showAIRecommend',
              'AI推薦',
              homeBlocks['showAIRecommend'] ?? true,
            ),
            _buildBlockToggle(
              ref,
              'showHotMovies',
              '熱門影片',
              homeBlocks['showHotMovies'] ?? true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockToggle(
    WidgetRef ref,
    String blockKey,
    String label,
    bool isEnabled,
  ) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: isEnabled,
      onChanged: (value) {
        final newBlocks = Map<String, bool>.from(
          ref.read(settingsStoreProvider).homeBlocks,
        );
        newBlocks[blockKey] = value;
        ref.read(settingsStoreProvider.notifier).updateHomeBlocks(newBlocks);
      },
    );
  }
}
