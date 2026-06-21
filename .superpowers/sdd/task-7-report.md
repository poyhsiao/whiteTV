# Task 7 Report: ReorderableTabList Widget

## Status: COMPLETED

## Summary

Successfully implemented the ReorderableTabList widget with drag-and-drop reordering and per-tab visibility toggles. All tests pass (9/9).

## Files Created

| File | Purpose |
|------|---------|
| `lib/features/settings/widgets/reorderable_tab_list.dart` | Widget implementation |
| `test/features/settings/widgets/reorderable_tab_list_test.dart` | Widget tests |

## Widget Features

- **Drag-and-drop reordering**: Uses `ReorderableListView` with `ReorderableDragStartListener` for explicit drag handle control
- **Visibility toggle**: Each tab has an `IconButton` that toggles between `Icons.visibility` and `Icons.visibility_off`
- **Hint text**: Shows "長按拖曳可調整順序" at the bottom in grey color
- **Integration**: Uses `tabNavigationStoreProvider` from `TabNavigationStore` for state management

## Test Results

All 9 tests passed:

1. `renders all six default tabs` - Verifies all 6 default tabs are displayed
2. `shows drag handle icon for each tab` - Checks drag handle icons are present
3. `shows visibility icon for each tab` - Verifies visibility icons for all tabs
4. `toggles tab visibility when visibility icon is tapped` - Tests toggle interaction
5. `shows hint text at bottom` - Verifies hint text is displayed
6. `hint text has grey color` - Checks hint text styling
7. `all tabs are visible by default` - Verifies default visibility state
8. `can toggle multiple tabs visibility independently` - Tests multiple toggles
9. `toggling visibility does not change tab order` - Verifies reorder integrity

## Commit

```
commit 48223da
feat: add ReorderableTabList widget with visibility toggle
```

## Architecture

The widget follows existing patterns in the project:
- Uses `ConsumerWidget` from `flutter_riverpod`
- Integrates with `TabNavigationStore` via `tabNavigationStoreProvider`
- Matches styling and layout patterns from `TabOrderEditor` widget
- Uses `ValueKey` for stable widget identity during reorder operations

## Test Pattern

Tests follow the project's established pattern:
- `ProviderScope` for Riverpod dependency injection
- `MaterialApp` + `Scaffold` wrapper
- `pumpAndSettle()` for async settling
- Widget finder patterns: `find.widgetWithText`, `find.descendant`, `find.byIcon`

## Files Modified (Not Created)

- `lib/features/settings/widgets/reorderable_tab_list.dart` (new)
- `test/features/settings/widgets/reorderable_tab_list_test.dart` (new)
