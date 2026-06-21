import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/stores/tab_navigation_store.dart';

/// A reorderable list of navigation tabs with drag-and-drop reordering
/// and per-tab visibility toggles.
class ReorderableTabList extends ConsumerWidget {
  const ReorderableTabList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabNavigationStoreProvider);
    final tabs = state.tabs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            ref
                .read(tabNavigationStoreProvider.notifier)
                .reorder(oldIndex, newIndex);
          },
          children: tabs.asMap().entries.map((entry) {
            final tab = entry.value;
            final index = entry.key;

            return ReorderableDragStartListener(
              key: ValueKey(tab.id),
              index: index,
              child: ListTile(
                title: Text(tab.label),
                leading: const Icon(Icons.drag_handle),
                trailing: IconButton(
                  icon: Icon(
                    tab.isVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    ref
                        .read(tabNavigationStoreProvider.notifier)
                        .setVisibility(tab.id, !tab.isVisible);
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '長按拖曳可調整順序',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
