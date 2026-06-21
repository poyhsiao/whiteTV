# Task 6 Report: TabConfig and TabNavigationStore

## Status: DONE

## Files Created

- `lib/features/settings/models/tab_config.dart` - TabConfig data model with id, label, isVisible, order, copyWith
- `lib/features/settings/stores/tab_navigation_store.dart` - TabNavigationStore with visibility, reorder, and defaults
- `test/features/settings/stores/tab_navigation_store_test.dart` - 29 tests covering all functionality

## Implementation Details

### TabConfig Model (`lib/features/settings/models/tab_config.dart`)

Immutable data class for tab configuration:
- `id` (String) - unique identifier (e.g. 'home', 'categories')
- `label` (String) - display label in navigation UI
- `isVisible` (bool, default true) - whether tab is shown in navigation
- `order` (int, default 0) - sort position; lower values appear first
- `copyWith()` - immutable copy with field overrides
- `defaultTabs` constant - 6 standard tabs: 首頁, 分類, 直播, 搜尋, 收藏, 設定

### TabNavigationStore (`lib/features/settings/stores/tab_navigation_store.dart`)

StateNotifier-based store following project's Riverpod patterns:
- `visibleTabs` getter - filters hidden tabs and sorts by order
- `isVisible(String id)` - checks if a tab is currently visible
- `setVisibility(String id, bool visible)` - shows/hides a specific tab
- `reorder(int oldIndex, int newIndex)` - moves tab and recalculates all order values
- `restoreDefaults()` - resets to defaultTabs configuration

### Test Coverage (29 tests)

**TabConfig model tests (5):**
- Default values, copyWith updates, copyWith preservation, equality, toString

**defaultTabs constant tests (4):**
- Contains 6 tabs, correct ids in order, all visible, sequential order values

**TabNavigationState tests (3):**
- visibleTabs filtering and sorting, empty when all hidden, copyWith

**TabNavigationStore tests (15):**
- Initialization with defaults
- isVisible: true for visible, false for unknown, false after hiding
- setVisibility: hide, show, no-op on unknown, no side effects
- reorder: move tab, recalculate orders, invalid bounds handling, data preservation
- restoreDefaults: full reset, order restoration

**Provider tests (2):**
- ProviderContainer access, state update reflection

## Test Results

```
00:00 +0: loading tab_navigation_store_test.dart
00:01 +29: All tests passed!
```

## Static Analysis

```
Analyzing 3 items...
No issues found!
```

## Commits

- `feat(settings): add TabConfig and TabNavigationStore`
