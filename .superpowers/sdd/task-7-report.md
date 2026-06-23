# Task 7 Report: LiveStore Integration with Timeshift Buffering

## Status: DONE

## Summary

Integrated timeshift buffering into `LiveStore.playChannel()` flow per SDD task brief.

## Changes Made

### 1. `lib/features/live/domain/services/live_service.dart`
Added two methods:
- `Future<void> startClientBuffer(String channelId, Duration duration)` - delegates to `TimeshiftManager`
- `Future<void> stopClientBuffer()` - delegates to `TimeshiftManager`

### 2. `lib/features/live/presentation/providers/live_store.dart`
- Added `SettingsState?` and `TimeshiftManager?` as nullable fields (backward compatible with existing tests)
- Updated `liveStoreProvider` to inject `settingsStoreProvider` and `timeshiftManagerProvider`
- Added `playChannel(M3uChannel channel)` method implementing:
  1. Starts client buffer with `settings.timeshiftBufferDuration` (default 30 min)
  2. Checks service-side timeshift support via `isServiceSideSupported()`
  3. If supported: uses `getServiceSideStream()` for server-side timeshift
  4. If not supported: falls back to `selectChannel()` for client-side buffer mode

### 3. `test/features/live/presentation/providers/live_store_test.dart`
- Added `FakeM3uParser`, `FakeEpgManager`, `FakeTimeshiftManager`, `FakeSettingsStorageService`
- Added `FakeLiveService extends LiveService` with test doubles
- Updated `ProviderContainer` overrides to use `liveStoreProvider.overrideWith()` directly

## Architecture

```
playChannel(channel)
  1. _service.startClientBuffer(channelId, Duration(minutes: bufferDuration))
  2. _timeshiftManager.isServiceSideSupported(channelId)
     -> true:  _timeshiftManager.getServiceSideStream() -> startTimeshift()
     -> false: selectChannel() (client-side buffer mode)
```

## Test Results

| Test Suite | Result |
|------------|--------|
| `flutter analyze` on modified lib files | No issues |
| `live_store_test.dart` | 15/15 passed |
| Full `test/features/live/` suite | 127 passed, 6 pre-existing failures (unrelated - missing mock methods in other test files) |

## Commit

```
f1abee5 - feat: integrate LiveStore with timeshift buffering (Task 7)
```

## Files Modified

- `lib/features/live/domain/services/live_service.dart`
- `lib/features/live/presentation/providers/live_store.dart`
- `test/features/live/presentation/providers/live_store_test.dart`
