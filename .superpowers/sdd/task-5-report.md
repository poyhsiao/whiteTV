# Task 5 Report: Timeshift Playback BDD Tests

## Status: DONE

## Files Modified

- `test/features/live/live_timeshift_bdd_test.dart` (17 tests, all passing)

## Test Scenarios

### Scenario 1: User drags timeline to seek backward (3 tests)
- GIVEN user is watching live / WHEN user drags the timeline backward / THEN player starts playing timeshift content at the requested offset
- GIVEN user is watching live / WHEN user seeks to a specific position / THEN the requested offset is recorded in state
- GIVEN user is watching live / WHEN user starts timeshift / THEN the manager receives the correct channel and stream URL

### Scenario 2: Server-side timeshift unsupported (5 tests)
- GIVEN server-side timeshift API responds with 404 / WHEN user attempts timeshift / THEN system falls back to local client buffer
- GIVEN service-side timeshift is reported as unsupported / WHEN we check isServiceSideSupported / THEN it returns false
- GIVEN service-side timeshift is supported / WHEN we check isServiceSideSupported / THEN it returns true
- GIVEN server-side stream URL is not available / WHEN getServiceSideStream is called / THEN null is returned indicating fallback is needed
- GIVEN server-side stream URL is available / WHEN getServiceSideStream is called / THEN the URL is returned

### Scenario 3: User returns to live (3 tests)
- GIVEN user is watching timeshift content / WHEN user taps "GO LIVE" / THEN player returns to the live stream
- GIVEN user is in timeshift mode / WHEN user stops timeshift / THEN the timeshift manager is deactivated
- GIVEN user is watching live / WHEN timeshift has not been started / THEN stopTimeshift still returns loaded state cleanly

### Scenario 4: Timeshift mode state transitions (3 tests)
- GIVEN initial live state / WHEN timeshift starts / THEN status transitions from loaded to timeshift
- GIVEN timeshift is active / WHEN user returns to live / THEN status transitions from timeshift back to loaded
- GIVEN timeshift is active / WHEN user starts timeshift again at a different position / THEN the new offset replaces the previous one

### Scenario 5: 中文 BDD 驗收情境 (3 tests)
- GIVEN 用戶正在觀看直播 / WHEN 用戶拖曳時間軸 / THEN 播放器開始播放時移內容
- GIVEN 服務端不支援 / WHEN 用戶嘗試時移 / THEN 系統使用本地緩存播放
- GIVEN 用戶正在觀看時移內容 / WHEN 用戶點擊直播中按鈕 / THEN 播放器回到直播串流

## Test Results

```
00:00 +0: loading live_timeshift_bdd_test.dart
00:00 +17: All tests passed!
```

## Commits

- `feat(live): add BDD tests for timeshift playback`
