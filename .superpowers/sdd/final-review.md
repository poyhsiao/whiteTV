# Code Review: whiteTV Timeshift and Tab Customization Feature

## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 0     | pass   |
| HIGH     | 3     | warn   |
| MEDIUM   | 2     | info   |
| LOW      | 5     | note   |

**Verdict: NEEDS_CHANGES** — 3 HIGH issues must be resolved before merge.

---

## CRITICAL Issues

None identified.

---

## HIGH Issues

### [HIGH-1] MockTimeshiftManager missing interface methods (3 test files)

**Files:**
- `test/features/live/live_bdd_test.dart:120`
- `test/features/live/live_service_fallback_test.dart:123`

**Issue:** `TimeshiftManager` interface added 4 new methods in commit `8e83ca1`:
- `isServiceSideSupported()`
- `getServiceSideStream()`
- `startClientBuffer()`
- `stopClientBuffer()`

`MockTimeshiftManager` in both test files implements `TimeshiftManager` but does not implement these 4 new methods, causing compile errors.

**Evidence:**
```
error • Missing concrete implementations of 'TimeshiftManager.getServiceSideStream', 
'TimeshiftManager.isServiceSideSupported', 'TimeshiftManager.startClientBuffer', 
and 'TimeshiftManager.stopClientBuffer'.
```

**Fix:** Add stub implementations to `MockTimeshiftManager` in both files:
```dart
@override
Future<bool> isServiceSideSupported(String channelId) async => false;

@override
Future<String?> getServiceSideStream(String channelId, Duration startOffset, Duration endOffset) async => null;

@override
Future<void> startClientBuffer(String channelId, Duration duration) async {}

@override
Future<void> stopClientBuffer() async {}
```

---

### [HIGH-2] Unused field `_apiClient` in TimeshiftServiceAdapter

**File:** `lib/features/live/domain/services/timeshift_service_adapter.dart:10`

```dart
final ApiClient _apiClient;
```

**Issue:** Field is assigned in constructor but never used. The TODO comments indicate LunaTV API integration is not yet implemented.

**Fix:** Either:
1. Remove the unused field and constructor parameter if not needed yet, OR
2. Use the field when implementing the TODO items

---

### [HIGH-3] Test failures prevent full verification

**Issue:** `flutter test` exited with code 1. Multiple tests failed in `source_switcher_test.dart` and `navigation_factory_test.dart` (140+ tests passed, then failures began). Cannot fully verify behavior until compile errors in HIGH-1 are fixed.

**Fix:** Resolve HIGH-1 first, then re-run tests.

---

## MEDIUM Issues

### [MEDIUM-1] Dead code in TabNavigationState.restoreDefaults()

**File:** `lib/features/settings/stores/tab_navigation_store.dart:74-79`

```dart
void restoreDefaults() {
  state = const TabNavigationState(tabs: []);  // This assignment is immediately overwritten
  state = TabNavigationState(
    tabs: List<TabConfig>.from(defaultTabs),
  );
}
```

**Issue:** First assignment to empty state is immediately overwritten. Minor inefficiency.

**Fix:** Remove line 76:
```dart
void restoreDefaults() {
  state = TabNavigationStore(
    tabs: List<TabConfig>.from(defaultTabs),
  );
}
```

---

### [MEDIUM-2] TimeshiftClientBuffer lacks buffer data management

**File:** `lib/features/live/domain/services/timeshift_client_buffer.dart`

**Issue:** `start()` and `stop()` exist but `_bufferedDuration` is always set to `Duration.zero` and never actually accumulates buffered data. This is a stub implementation with no real buffering logic.

**Note:** This may be intentional as a placeholder for future implementation. If so, add a comment indicating it's a stub:
```dart
// TODO: Implement actual segment buffering
_bufferedDuration = Duration.zero;
```

---

## LOW Issues

### [LOW-1] Unused import in test file

**File:** `test/bdd/steps/home_steps.dart:4`

```dart
import 'package:white_tv/core/api/models.dart';
```

**Fix:** Remove unused import.

---

### [LOW-2] Unnecessary null comparison

**File:** `test/bdd/steps/home_steps.dart:39:58`

```dart
The operand can't be 'null', so the condition is always 'true'.
```

**Fix:** Remove the always-true null check.

---

### [LOW-3] Multiple unused imports in test files

- `test/features/detail/detail_parental_gate_test.dart` — unused Material, flutter_riverpod, shared_preferences, parental_control_service imports
- `test/features/detail/source_selector_badge_test.dart` — unused detail_store import
- `test/features/settings/widgets/reorderable_tab_list_test.dart` — unused tab_navigation_store import
- `test/unit/features/category/category_content_store_test.dart` — unused flutter_riverpod, category_content_state imports

**Fix:** Remove unused imports to reduce noise and improve analysis signal.

---

### [LOW-4] Unused local variable

**File:** `test/features/settings/account_settings_card_test.dart:68`

```dart
final stateChanged = ...
```

**Fix:** Remove or use the variable.

---

### [LOW-5] `withOpacity` deprecation warning

**File:** `lib/features/live/presentation/widgets/timeshift_control_bar.dart:82`

```dart
color: Colors.black.withOpacity(0.8),
```

**Issue:** `withOpacity` is deprecated in Flutter 3.x; use `withValues(alpha: 0.8)` instead.

**Fix:** Update to `withValues(alpha: 0.8)`.

---

## Code Quality Assessment

### Spec Compliance: PASS

| Requirement | Implementation |
|-------------|----------------|
| TimeshiftManager interface extended | `isServiceSideSupported`, `getServiceSideStream`, `startClientBuffer`, `stopClientBuffer` added |
| TimeshiftClientBuffer for client-side fallback | `TimeshiftClientBuffer` class implemented |
| TimeshiftServiceAdapter for LunaTV integration | Stub with TODO comments, correctly returns `false`/`null` |
| TimeshiftMode enum (live/service/buffer) | 3-mode enum correctly implemented |
| TimeshiftControlBar updated to use mode | `isLive` replaced with `mode: TimeshiftMode` |
| TabConfig model | Immutable data class with id, label, isVisible, order, copyWith |
| TabNavigationStore | StateNotifier with visibility, reorder, restoreDefaults |
| ReorderableTabList widget | Drag-and-drop with visibility toggle |
| SettingsScreen integration | Tab 6 added, ReorderableTabList integrated |

### Pattern Compliance: PASS

- Immutability: TabConfig uses `copyWith`, no mutable fields
- Riverpod patterns: StateNotifier + StateNotifierProvider follow project convention
- Error handling: Service adapters correctly return safe defaults (false, null)
- Test structure: AAA pattern, descriptive test names with GIVEN/WHEN/THEN

### Test Coverage: PARTIAL

Tests exist and follow BDD structure, but cannot verify behavior due to compile errors. Once HIGH-1 is resolved, re-run to confirm.

---

## Recommendations

1. **Blocker:** Fix `MockTimeshiftManager` in 3 test files immediately
2. **High Priority:** Remove unused `_apiClient` field or add TODO explaining why it's there
3. **Medium Priority:** Clean up dead code in `restoreDefaults()`
4. **Low Priority:** Remove all unused imports across test files
5. **Cleanup:** Fix `withOpacity` deprecation before it accumulates

---

## Files Changed

| File | Lines | Change |
|------|-------|--------|
| `lib/features/live/domain/repositories/timeshift_manager.dart` | +32 | Interface extension |
| `lib/features/live/domain/services/timeshift_client_buffer.dart` | +54 | New service |
| `lib/features/live/domain/services/timeshift_service_adapter.dart` | +44 | New adapter (stub) |
| `lib/features/live/presentation/screens/live_player_screen.dart` | +4/-1 | Mode integration |
| `lib/features/live/presentation/widgets/timeshift_control_bar.dart` | +70/-18 | Mode enum + UI |
| `lib/features/settings/models/tab_config.dart` | +65 | New model |
| `lib/features/settings/settings_screen.dart` | +4/-1 | Tab 6 integration |
| `lib/features/settings/stores/tab_navigation_store.dart` | +86 | New store |
| `lib/features/settings/widgets/reorderable_tab_list.dart` | +63 | New widget |
| Test files (10) | +~1600 | BDD + unit tests |

---

## Conclusion

The implementation is well-structured and follows project conventions. The core timeshift mode system and tab customization store are sound. However, compile errors in test files must be resolved before merge. The unused field and various lint warnings should also be addressed.
