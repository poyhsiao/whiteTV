import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/models/tab_config.dart';
import 'package:white_tv/features/settings/stores/tab_navigation_store.dart';

void main() {
  group('TabConfig', () {
    test('has correct default values', () {
      const tab = TabConfig(id: 'home', label: '首頁');
      expect(tab.id, 'home');
      expect(tab.label, '首頁');
      expect(tab.isVisible, true);
      expect(tab.order, 0);
    });

    test('copyWith creates new instance with updated values', () {
      const tab = TabConfig(id: 'home', label: '首頁');
      final updated = tab.copyWith(isVisible: false, order: 3);
      expect(updated.id, 'home');
      expect(updated.label, '首頁');
      expect(updated.isVisible, false);
      expect(updated.order, 3);
    });

    test('copyWith preserves existing values when not overridden', () {
      const tab = TabConfig(
        id: 'live',
        label: '直播',
        isVisible: false,
        order: 2,
      );
      final updated = tab.copyWith(label: 'Live TV');
      expect(updated.id, 'live');
      expect(updated.label, 'Live TV');
      expect(updated.isVisible, false);
      expect(updated.order, 2);
    });

    test('equality is based on all fields', () {
      const tab1 = TabConfig(id: 'home', label: '首頁', order: 0);
      const tab2 = TabConfig(id: 'home', label: '首頁', order: 0);
      const tab3 = TabConfig(id: 'home', label: '首页', order: 0);
      expect(tab1, equals(tab2));
      expect(tab1 == tab3, false);
    });

    test('toString includes all fields', () {
      const tab = TabConfig(id: 'home', label: '首頁', isVisible: true, order: 0);
      expect(tab.toString(), contains('id: home'));
      expect(tab.toString(), contains('label: 首頁'));
      expect(tab.toString(), contains('isVisible: true'));
    });
  });

  group('defaultTabs', () {
    test('contains six tabs', () {
      expect(defaultTabs.length, 6);
    });

    test('has correct ids in default order', () {
      expect(defaultTabs[0].id, 'home');
      expect(defaultTabs[1].id, 'categories');
      expect(defaultTabs[2].id, 'live');
      expect(defaultTabs[3].id, 'search');
      expect(defaultTabs[4].id, 'favorites');
      expect(defaultTabs[5].id, 'settings');
    });

    test('all default tabs are visible', () {
      for (final tab in defaultTabs) {
        expect(tab.isVisible, true);
      }
    });

    test('order values are sequential starting from 0', () {
      for (var i = 0; i < defaultTabs.length; i++) {
        expect(defaultTabs[i].order, i);
      }
    });
  });

  group('TabNavigationState', () {
    test('visibleTabs returns only visible tabs sorted by order', () {
      final tabs = [
        const TabConfig(id: 'a', label: 'A', isVisible: true, order: 2),
        const TabConfig(id: 'b', label: 'B', isVisible: false, order: 0),
        const TabConfig(id: 'c', label: 'C', isVisible: true, order: 1),
      ];
      final state = TabNavigationState(tabs: tabs);

      final visible = state.visibleTabs;
      expect(visible.length, 2);
      expect(visible[0].id, 'c');
      expect(visible[1].id, 'a');
    });

    test('visibleTabs returns empty list when all tabs hidden', () {
      final tabs = [
        const TabConfig(id: 'a', label: 'A', isVisible: false, order: 0),
        const TabConfig(id: 'b', label: 'B', isVisible: false, order: 1),
      ];
      final state = TabNavigationState(tabs: tabs);
      expect(state.visibleTabs, isEmpty);
    });

    test('copyWith creates new instance with updated tabs', () {
      const state = TabNavigationState(tabs: []);
      final tabs = [const TabConfig(id: 'x', label: 'X')];
      final updated = state.copyWith(tabs: tabs);
      expect(updated.tabs.length, 1);
      expect(updated.tabs[0].id, 'x');
    });
  });

  group('TabNavigationStore', () {
    late TabNavigationStore store;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      store = container.read(tabNavigationStoreProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initializes with default tabs', () {
      final state = container.read(tabNavigationStoreProvider);
      expect(state.tabs.length, 6);
      expect(state.tabs[0].id, 'home');
    });

    group('isVisible', () {
      test('returns true for visible tabs', () {
        expect(store.isVisible('home'), true);
        expect(store.isVisible('categories'), true);
      });

      test('returns false for non-existent tab id', () {
        expect(store.isVisible('nonexistent'), false);
      });

      test('returns false after setting tab hidden', () {
        store.setVisibility('home', false);
        expect(store.isVisible('home'), false);
      });
    });

    group('setVisibility', () {
      test('hides a tab', () {
        store.setVisibility('home', false);
        expect(store.isVisible('home'), false);
        // Other tabs remain visible
        expect(store.isVisible('categories'), true);
      });

      test('shows a previously hidden tab', () {
        store.setVisibility('home', false);
        store.setVisibility('home', true);
        expect(store.isVisible('home'), true);
      });

      test('does nothing for unknown tab id', () {
        final tabsBefore = store.state.tabs;
        store.setVisibility('unknown', false);
        expect(store.state.tabs.length, tabsBefore.length);
      });

      test('does not affect other tabs when hiding', () {
        store.setVisibility('live', false);
        expect(store.isVisible('home'), true);
        expect(store.isVisible('search'), true);
        expect(store.isVisible('live'), false);
      });
    });

    group('reorder', () {
      test('moves tab from old index to new index', () {
        store.reorder(0, 2);
        expect(store.state.tabs[0].id, 'categories');
        expect(store.state.tabs[1].id, 'live');
        expect(store.state.tabs[2].id, 'home');
      });

      test('recalculates order values after reorder', () {
        store.reorder(0, 3);
        for (var i = 0; i < store.state.tabs.length; i++) {
          expect(store.state.tabs[i].order, i);
        }
      });

      test('does nothing when oldIndex is out of bounds', () {
        final tabsBefore = store.state.tabs;
        store.reorder(-1, 0);
        expect(store.state.tabs, equals(tabsBefore));
        store.reorder(10, 0);
        expect(store.state.tabs, equals(tabsBefore));
      });

      test('does nothing when newIndex is out of bounds', () {
        final tabsBefore = store.state.tabs;
        store.reorder(0, 10);
        expect(store.state.tabs, equals(tabsBefore));
        store.reorder(0, -1);
        expect(store.state.tabs, equals(tabsBefore));
      });

      test('preserves tab data during reorder', () {
        final originalTab = store.state.tabs[0];
        store.reorder(0, 2);
        expect(store.state.tabs[2].id, originalTab.id);
        expect(store.state.tabs[2].label, originalTab.label);
        expect(store.state.tabs[2].isVisible, originalTab.isVisible);
      });
    });

    group('restoreDefaults', () {
      test('resets all tabs to default configuration', () {
        store.setVisibility('home', false);
        store.reorder(0, 2);
        store.restoreDefaults();

        final state = container.read(tabNavigationStoreProvider);
        expect(state.tabs.length, 6);
        expect(state.tabs[0].id, 'home');
        expect(state.tabs[0].isVisible, true);
        expect(store.isVisible('home'), true);
      });

      test('restores order after restoreDefaults', () {
        store.reorder(2, 0);
        store.reorder(0, 5);
        store.restoreDefaults();

        final state = container.read(tabNavigationStoreProvider);
        for (var i = 0; i < state.tabs.length; i++) {
          expect(state.tabs[i].order, i);
        }
      });
    });
  });

  group('tabNavigationStoreProvider', () {
    test('can be accessed via ProviderContainer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final store = container.read(tabNavigationStoreProvider.notifier);
      expect(store.state.tabs.length, 6);
    });

    test('notifier state updates are reflected in provider', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final store = container.read(tabNavigationStoreProvider.notifier);
      store.setVisibility('home', false);

      final updatedState = container.read(tabNavigationStoreProvider);
      expect(updatedState.tabs.firstWhere((t) => t.id == 'home').isVisible,
          false);
    });
  });
}
