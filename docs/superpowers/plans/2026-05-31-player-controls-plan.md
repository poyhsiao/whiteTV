# 播放器控制項完整實作計劃

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作 whiteTV 播放器缺少的 6 個控制項（上一集/下一集、音量控制、集數選擇、來源選擇、全螢幕、設定），支援 TV remote 和 Mobile touch 操作

**Architecture:** 
- TV 和 Mobile 分開實作控制面板
- 控制欄使用定時器自動隱藏（5 秒閒置）
- 所有控制項 widget化，位於 `lib/features/player/widgets/`
- PlayerStore 新增狀態 providers 管理控制項狀態

**Tech Stack:** Flutter + Riverpod + media_kit

---

## Task 1: PlayerStore 新增狀態 Providers

**Files:**
- Modify: `lib/features/player/player_store.dart` (PlayerState + PlayerStore methods)
- Test: `test/features/player/player_store_test.dart` (新增測試)

- [ ] **Step 1: 寫失敗的測試 - 新增控制項狀態**

在 `test/features/player/player_store_test.dart` 末尾新增測試群組 `Player Controls State`，測試：
- `initial controls visibility is true`
- `initial volume is 1.0`
- `initial muted is false`
- `initial fullscreen is false`
- `initial current episode is 1`
- `initial sources is empty`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/player_store_test.dart --name "initial controls"`
Expected: FAIL - `PlayerState` 沒有這些欄位

- [ ] **Step 3: 修改 PlayerState 新增欄位**

在 `lib/features/player/player_store.dart` 的 `PlayerState` class 新增：
```dart
final bool controlsVisible;
final double volume;
final bool isMuted;
final bool isFullscreen;
final int currentEpisode;
final int totalEpisodes;
final List<VideoSource> availableSources;
final VideoSource? currentSource;
```

- [ ] **Step 4: 更新 copyWith 方法**

新增所有新欄位的 copyWith 參數和賦值。

- [ ] **Step 5: PlayerStore 新增控制方法**

```dart
void setControlsVisible(bool visible)
void setVolume(double volume)
void toggleMute()
void toggleFullscreen()
void setCurrentEpisode(int episode)
void setTotalEpisodes(int total)
void setAvailableSources(List<VideoSource> sources)
void setCurrentSource(VideoSource source)
void nextEpisode()
void previousEpisode()
```

- [ ] **Step 6: 執行測試確認通過**

Run: `flutter test test/features/player/player_store_test.dart --name "initial controls"`
Expected: PASS

- [ ] **Step 7: 提交**

```bash
git add lib/features/player/player_store.dart test/features/player/player_store_test.dart
git commit -m "feat(player): add control state fields and methods to PlayerStore"
```

---

## Task 2: 上一集/下一集按鈕

**Files:**
- Create: `lib/features/player/widgets/episode_navigation.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/episode_navigation_test.dart`

- [ ] **Step 1: 寫失敗的測試**

Create `test/features/player/episode_navigation_test.dart`:
- `shows previous and next buttons`
- `previous button disabled on first episode`
- `next button disabled on last episode`
- `displays episode number`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/episode_navigation_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 EpisodeNavigation widget**

Create `lib/features/player/widgets/episode_navigation.dart`:
- Row包含 skip_previous IconButton、episode number Container、skip_next IconButton
- 邊界時禁用對應按鈕

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/features/player/episode_navigation_test.dart`
Expected: PASS

- [ ] **Step 5: 整合到 PlayerScreen _buildTVControls**

在播放/暫停按鈕後新增 EpisodeNavigation

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/widgets/episode_navigation.dart test/features/player/episode_navigation_test.dart lib/features/player/player_screen.dart
git commit -m "feat(player): add episode navigation buttons"
```

---

## Task 3: 音量控制

**Files:**
- Create: `lib/features/player/widgets/volume_control.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/volume_control_test.dart`

- [ ] **Step 1: 寫失敗的測試**

Create `test/features/player/volume_control_test.dart`:
- `shows volume icon`
- `shows muted icon when muted`
- `shows volume slider`
- `displays volume percentage`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/volume_control_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 VolumeControl widget**

Create `lib/features/player/widgets/volume_control.dart`:
- Row 包含 volume_off/up/down IconButton、Slider、percentage Text
- 根據 isMuted 和 volume 值顯示不同圖標

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/features/player/volume_control_test.dart`
Expected: PASS

- [ ] **Step 5: 整合到 PlayerScreen _buildTVControls**

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/widgets/volume_control.dart test/features/player/volume_control_test.dart lib/features/player/player_screen.dart
git commit -m "feat(player): add volume control widget"
```

---

## Task 4: 集數選擇器

**Files:**
- Create: `lib/features/player/widgets/episode_selector.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/episode_selector_test.dart`

- [ ] **Step 1: 寫失敗的測試**

Create `test/features/player/episode_selector_test.dart`:
- `shows episode button`
- `opens episode list on tap`
- `shows GridView of episodes in dialog`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/episode_selector_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 EpisodeSelector widget**

Create `lib/features/player/widgets/episode_selector.dart`:
- OutlinedButton 顯示 "第 X 集"
- tap 彈出 AlertDialog 顯示 GridView (6 columns)
- 當前集數高亮顯示

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/features/player/episode_selector_test.dart`
Expected: PASS

- [ ] **Step 5: 整合到 PlayerScreen _buildTVControls**

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/widgets/episode_selector.dart test/features/player/episode_selector_test.dart lib/features/player/player_screen.dart
git commit -m "feat(player): add episode selector dialog"
```

---

## Task 5: 來源選擇器

**Files:**
- Create: `lib/features/player/widgets/source_switcher.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/source_switcher_test.dart`

- [ ] **Step 1: 寫失敗的測試**

Create `test/features/player/source_switcher_test.dart`:
- `shows source button`
- `shows latency`
- `opens source list on tap`
- `marks auto-selected source`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/source_switcher_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 SourceSwitcher widget**

Create `lib/features/player/widgets/source_switcher.dart`:
- OutlinedButton 顯示來源名稱 + [自動] 標記
- tap 彈出 AlertDialog 顯示 ListView
- 每項顯示名稱、延遲ms、當前選擇圖標

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/features/player/source_switcher_test.dart`
Expected: PASS

- [ ] **Step 5: 整合到 PlayerScreen _buildTVControls**

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/widgets/source_switcher.dart test/features/player/source_switcher_test.dart lib/features/player/player_screen.dart
git commit -m "feat(player): add source switcher dialog"
```

---

## Task 6: 全螢幕切換

**Files:**
- Create: `lib/features/player/widgets/fullscreen_toggle.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/fullscreen_toggle_test.dart`

- [ ] **Step 1: 寫失敗的測試**

Create `test/features/player/fullscreen_toggle_test.dart`:
- `shows fullscreen icon when not fullscreen`
- `shows fullscreen exit icon when fullscreen`
- `calls onToggle when pressed`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/fullscreen_toggle_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 FullscreenToggle widget**

Create `lib/features/player/widgets/fullscreen_toggle.dart`:
- IconButton 根據 isFullscreen 顯示 fullscreen/fullscreen_exit 圖標

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/features/player/fullscreen_toggle_test.dart`
Expected: PASS

- [ ] **Step 5: 整合到 PlayerScreen _buildTVControls**

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/widgets/fullscreen_toggle.dart test/features/player/fullscreen_toggle_test.dart lib/features/player/player_screen.dart
git commit -m "feat(player): add fullscreen toggle button"
```

---

## Task 7: 設定面板

**Files:**
- Create: `lib/features/player/widgets/settings_panel.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/settings_panel_test.dart`

- [ ] **Step 1: 寫失敗的測試**

Create `test/features/player/settings_panel_test.dart`:
- `shows settings button`
- `opens settings dialog on tap`
- `shows subtitle options in dialog`

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/player/settings_panel_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 SettingsPanel widget**

Create `lib/features/player/widgets/settings_panel.dart`:
- IconButton 點擊彈出 AlertDialog
- 顯示字幕和音軌的 ChoiceChip 選項

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/features/player/settings_panel_test.dart`
Expected: PASS

- [ ] **Step 5: 整合到 PlayerScreen _buildTVControls**

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/widgets/settings_panel.dart test/features/player/settings_panel_test.dart lib/features/player/player_screen.dart
git commit -m "feat(player): add settings panel dialog"
```

---

## Task 8: 控制欄自動隱藏

**Files:**
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/player_screen_test.dart`

- [ ] **Step 1: 寫失敗的測試**

新增測試：controls auto-hide after 5 seconds

- [ ] **Step 2: 實作自動隱藏邏輯**

在 `_PlayerScreenState` 中：
- 新增 `_controlsHideTimer` 和 `_controlsLocked` 狀態
- 新增 `_resetControlsTimer()` 方法（5秒計時器）
- 新增 `_showControls()` 方法
- 新增 `_toggleControlsLock()` 方法

- [ ] **Step 3: 在 GestureDetector 中調用 _showControls**

用 GestureDetector 包裝影片區域，onTap呼叫 _showControls

- [ ] **Step 4: 在 _buildTVControls 中使用 controlsVisible 狀態**

控制項可見性根據 state.controlsVisible 和 _controlsLocked 決定

- [ ] **Step 5: 執行測試確認通過**

Run: `flutter test test/features/player/player_screen_test.dart`
Expected: PASS

- [ ] **Step 6: 提交**

```bash
git add lib/features/player/player_screen.dart
git commit -m "feat(player): add auto-hide controls with 5 second timer"
```

---

## Task 9: 整合測試覆蓋率驗證

- [ ] **Step 1: 執行覆蓋率測試**

Run: `flutter test --coverage`
Expected:80%+ line coverage for player feature

- [ ] **Step 2: 如覆蓋率不足，補充測試**

- [ ] **Step 3: 最終提交**

```bash
git add -A && git commit -m "feat(player): complete player controls implementation"
```

---

## Self-Review Checklist

1. **Spec coverage:** 
   - ✅ 上一集/下一集 - Task 2
   - ✅ 音量控制 - Task 3
   - ✅ 集數選擇 - Task 4
   - ✅ 來源選擇 - Task 5
   - ✅ 全螢幕 - Task 6
   - ✅ 設定面板 - Task 7
   - ✅ 控制欄自動隱藏 - Task 8

2. **Placeholder scan:** 無 "TBD" 或 "TODO"

3. **Type consistency:** 
   - `PlayerState` 欄位名稱一致
   - `VideoSource` 屬性使用 `id`, `url`, `name`, `latency`
