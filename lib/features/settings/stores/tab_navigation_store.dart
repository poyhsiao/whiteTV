import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/models/tab_config.dart';

class TabNavigationState {
  final List<TabConfig> tabs;

  const TabNavigationState({required this.tabs});

  TabNavigationState copyWith({List<TabConfig>? tabs}) {
    return TabNavigationState(tabs: tabs ?? this.tabs);
  }

  /// Tabs filtered by visibility and sorted by their [order] field.
  List<TabConfig> get visibleTabs {
    return List<TabConfig>.from(tabs)
        .where((t) => t.isVisible)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}

class TabNavigationStore extends StateNotifier<TabNavigationState> {
  TabNavigationStore()
      : super(
          const TabNavigationState(tabs: []),
        ) {
    state = TabNavigationState(
      tabs: List<TabConfig>.from(defaultTabs),
    );
  }

  /// Returns true if the tab with the given [id] is currently visible.
  bool isVisible(String id) {
    return state.tabs.any((t) => t.id == id && t.isVisible);
  }

  /// Sets the visibility of the tab identified by [id].
  /// Returns immediately if the tab is not found.
  void setVisibility(String id, bool visible) {
    final updatedTabs = <TabConfig>[];
    for (final tab in state.tabs) {
      if (tab.id == id) {
        updatedTabs.add(tab.copyWith(isVisible: visible));
      } else {
        updatedTabs.add(tab);
      }
    }
    state = state.copyWith(tabs: updatedTabs);
  }

  /// Moves a tab from [oldIndex] to [newIndex] in the tabs list and
  /// recalculates the [order] field for all tabs.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.tabs.length ||
        newIndex < 0 ||
        newIndex >= state.tabs.length) {
      return;
    }

    final updatedTabs = List<TabConfig>.from(state.tabs);
    final item = updatedTabs.removeAt(oldIndex);
    updatedTabs.insert(newIndex, item);

    // Recalculate order values based on new positions.
    final reordered = <TabConfig>[];
    for (var i = 0; i < updatedTabs.length; i++) {
      reordered.add(updatedTabs[i].copyWith(order: i));
    }

    state = state.copyWith(tabs: reordered);
  }

  /// Resets all tabs to the [defaultTabs] configuration.
  void restoreDefaults() {
    state = const TabNavigationState(tabs: []);
    state = TabNavigationState(
      tabs: List<TabConfig>.from(defaultTabs),
    );
  }
}

final tabNavigationStoreProvider =
    StateNotifierProvider<TabNavigationStore, TabNavigationState>((ref) {
  return TabNavigationStore();
});
