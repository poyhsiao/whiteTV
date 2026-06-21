import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/stores/tab_navigation_store.dart';

void main() {
  group('Feature: Tab 導航自訂', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    TabNavigationStore readStore() {
      return container.read(tabNavigationStoreProvider.notifier);
    }

    test(
      'GIVEN 用戶打開設定頁 '
      'WHEN 用戶點擊隱藏按鈕 '
      'THEN 導航列不再顯示該 Tab',
      () {
        final store = readStore();

        // Arrange: verify search tab is visible by default
        expect(store.isVisible('search'), isTrue);

        // Act: hide search tab
        store.setVisibility('search', false);

        // Assert: search tab no longer appears in visible tabs
        final visibleIds =
            store.state.visibleTabs.map((t) => t.id).toList();
        expect(visibleIds, isNot(contains('search')));
        expect(store.isVisible('search'), isFalse);
      },
    );

    test(
      'GIVEN 用戶打開設定頁 '
      'WHEN 用戶拖曳調整順序 '
      'THEN 導航列顯示新順序',
      () {
        final store = readStore();

        // Arrange: default order is home, categories, live, search, favorites, settings
        expect(store.state.visibleTabs[4].id, 'favorites');

        // Act: move favorites from index 4 to index 1
        store.reorder(4, 1);

        // Assert: favorites is now at position 1
        expect(store.state.visibleTabs[1].id, 'favorites');
      },
    );

    test(
      'GIVEN 用戶已自訂設定 '
      'WHEN 用戶點擊還原預設 '
      'THEN 所有 Tab 回到預設',
      () {
        final store = readStore();

        // Arrange: make customizations
        store.setVisibility('search', false);
        store.reorder(0, 5); // move home to end

        // Verify customizations took effect
        expect(store.isVisible('search'), isFalse);

        // Act: restore defaults
        store.restoreDefaults();

        // Assert: all tabs back to default
        expect(store.isVisible('search'), isTrue);
        expect(store.state.visibleTabs[0].id, 'home');
        expect(store.state.visibleTabs.length, 6);
      },
    );
  });
}
