import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_store.dart';

/// 首頁區塊顯示開關設定頁
/// 參照: docs/spec/UI_UX.md Section 3.2

class HomeBlockSettings extends ConsumerWidget {
  const HomeBlockSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);

    final blocks = <MapEntry<String, String>>[
      const MapEntry('showRecentWatch', '最近觀看'),
      const MapEntry('showLive', '直播入口'),
      const MapEntry('showCategories', '分類內容'),
      const MapEntry('showAIRecommend', '為你推薦'),
      const MapEntry('showHotMovies', '熱門電影'),
    ];

    return ListView(
      children: blocks.map((entry) {
        final isEnabled = settings.homeBlocks[entry.key] ?? true;
        return SwitchListTile(
          title: Text(entry.value),
          subtitle: Text(isEnabled ? '顯示' : '隱藏'),
          value: isEnabled,
          onChanged: (value) {
            final updated = Map<String, bool>.from(settings.homeBlocks);
            updated[entry.key] = value;
            ref.read(settingsStoreProvider.notifier).updateHomeBlocks(updated);
          },
        );
      }).toList(),
    );
  }
}
