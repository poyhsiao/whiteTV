import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_store.dart';

class TabOrderEditor extends ConsumerWidget {
  const TabOrderEditor({super.key});

  static const _tabLabels = {
    'home': '首頁',
    'categories': '分類',
    'live': '直播',
    'search': '搜尋',
    'favorites': '收藏',
    'settings': '設定',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final tabOrder = settings.tabOrder.isEmpty
        ? ['home', 'categories', 'live', 'search', 'favorites', 'settings']
        : settings.tabOrder;

    return ReorderableListView(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final newOrder = List<String>.from(tabOrder);
        final item = newOrder.removeAt(oldIndex);
        newOrder.insert(newIndex, item);
        ref.read(settingsStoreProvider.notifier).updateTabOrder(newOrder);
      },
      children: tabOrder.asMap().entries.map((entry) {
        final label = _tabLabels[entry.value] ?? entry.value;
        return ReorderableDragStartListener(
          key: ValueKey(entry.value),
          index: entry.key,
          child: ListTile(
            title: Text(label),
            leading: const Icon(Icons.drag_handle),
          ),
        );
      }).toList(),
    );
  }
}
