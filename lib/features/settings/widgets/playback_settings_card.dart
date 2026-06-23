import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/widgets/source_blocklist_tile.dart';

class PlaybackSettingsCard extends ConsumerWidget {
  const PlaybackSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAutoPlaySection(ref, settings),
          const SizedBox(height: 16),
          _buildDefaultQualitySection(ref, settings),
          const SizedBox(height: 16),
          _buildAutoSelectSourceSection(ref, settings),
          const SizedBox(height: 16),
          _buildSourceBlocklistSection(),
          const SizedBox(height: 16),
          _buildTimeshiftBufferSection(ref, settings),
        ],
      ),
    );
  }

  Widget _buildTimeshiftBufferSection(WidgetRef ref, SettingsState settings) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '時移緩衝',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RadioListTile<int>(
              title: const Text('15 分鐘', style: TextStyle(color: Colors.white)),
              value: 15,
              groupValue: settings.timeshiftBufferDuration,
              onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
            ),
            RadioListTile<int>(
              title: const Text('30 分鐘', style: TextStyle(color: Colors.white)),
              value: 30,
              groupValue: settings.timeshiftBufferDuration,
              onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
            ),
            RadioListTile<int>(
              title: const Text('60 分鐘', style: TextStyle(color: Colors.white)),
              value: 60,
              groupValue: settings.timeshiftBufferDuration,
              onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoPlaySection(WidgetRef ref, SettingsState settings) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: SwitchListTile(
        title: const Text('自動播放', style: TextStyle(color: Colors.white)),
        subtitle: const Text(
          '開啟後自動播放下一集',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        value: settings.autoPlay,
        onChanged: (value) {
          ref.read(settingsStoreProvider.notifier).updateAutoPlay(value);
        },
      ),
    );
  }

  Widget _buildDefaultQualitySection(WidgetRef ref, SettingsState settings) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '預設畫質',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['auto', '1080p', '720p', '480p', '360p'].map((
                quality,
              ) {
                final isSelected = settings.defaultQuality == quality;
                return ChoiceChip(
                  label: Text(quality),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(settingsStoreProvider.notifier)
                          .updateDefaultQuality(quality);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoSelectSourceSection(WidgetRef ref, SettingsState settings) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: SwitchListTile(
        title: const Text('自動選擇來源', style: TextStyle(color: Colors.white)),
        subtitle: const Text(
          '自動選擇最快的影片來源',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        value: settings.autoSelectSource,
        onChanged: (value) {
          ref
              .read(settingsStoreProvider.notifier)
              .updateAutoSelectSource(value);
        },
      ),
    );
  }

  Widget _buildSourceBlocklistSection() {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '來源封鎖',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const SourceBlocklistTile(),
          ],
        ),
      ),
    );
  }
}
