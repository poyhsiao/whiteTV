# whiteTV TDD+BDD 開發計劃
**基於**: `docs/spec/ARCHITECTURE.md` (v2.0) + `docs/spec/UI_UX.md` (v1.0)
**版本**: v1.0 · **日期**: 2026-07-13
**方法論**: TDD (Red-Green-Refactor) + BDD (Gherkin Scenarios)

---

## 現況診斷

| 類別 | 已實作 | 缺口 |
|------|--------|------|
| **P0** | 首頁分類✅ 影片播放✅ 來源切換✅ 設定頁(LunaTV URL+登入)✅ | 主題切換❌ 自動播放下一集❌ |
| **P1** | 搜尋✅ 收藏✅ 播放記錄✅ IPTV直播(基礎)✅ | TV遙控器對應❌ TV Tab順序拖曳❌ 來源屏蔽❌ |
| **P2** | AI推薦(clean-arch)✅ YouTube整合✅ | 全部基本覆蓋 |
| **Spec UX** | 大部分覆蓋 | **家長鎖❌ QR輸入(TV)❌ 淺色主題❌ 訊號異常UI❌ 來源屏蔽UI❌ 下一集自動播放邏輯❌ |

---

## Phase 1: P0 缺口弥補 — 主題 + 自動播放

### 為何先做
P0 是核心功能。主題切換和自動播放是 UI_UX spec 白紙黑字寫的「必備」設定項，目前只是 stub。

### 1.1 主題切換 (深色/淺色)

**Spec 來源**: `UI_UX.md §13.1` —「主題：深色/淺色（預設深色）」

**現狀**: `lib/core/theme/app_theme.dart` 有 `darkTheme`，`settings_store.dart` 有 `themeMode`。

#### TDD Red — 寫測試
```
test/features/settings/settings_store_test.dart
test/features/settings/settings_theme_bdd_test.dart  (new)
```
BDD scenarios:
- `Scenario: User toggles theme to light mode`
- `Scenario: Theme persists across app restart`

#### TDD Green — 實作
- `app_theme.dart`: 加入 `lightTheme` (oklch 調整)
- `settings_store.dart`: `themeMode` Provider + SharedPreferences persistence
- `main.dart`: 根據 `themeMode` 動態設定 `ThemeData`

#### BDD Verify
跑 `flutter test test/features/settings/settings_theme_bdd_test.dart`

---

### 1.2 自動播放下一集

**Spec 來源**: `UI_UX.md §13.1` —「自動播放：下一集自動播放」

**現狀**: `player_store.dart` 有 `autoPlay` 欄位但可能未完整串接。

#### TDD Red
```
test/features/player/player_store_test.dart
  - autoPlay_enabled_episode_completes_should_play_next
  - autoPlay_disabled_should_not_autoplay
test/bdd/steps/player_steps.dart (extend)
```

#### TDD Green
- `player_store.dart`: 實作 `handleEpisodeComplete()` 根據 `autoPlay` 自動切換集數
- `settings_store.dart`: `autoPlayEnabled` 開關
- `player_screen.dart`: 監聽 episode complete 事件

#### BDD Verify
`flutter test test/features/player/ player_store_test.dart`

---

## Phase 2: P1 缺口 — TV 適配 + 來源屏蔽 + 家長鎖

### 2.1 TV 遙控器按鍵對應

**Spec 來源**: `UI_UX.md §15.1-§15.4`

**現狀**: `core/input/keyboard_handler.dart` + `core/device/` 有部分實作，但缺少完整遙控器映射。

#### TDD Red
```
test/platform/tv/remote_handler_test.dart  (extend)
test/bdd/steps/input_steps.dart  (extend)
```
Scenarios:
- `Scenario: OK button confirms selection on TV`
- `Scenario: D-pad navigation moves focus correctly`
- `Scenario: Long-press fast-forward triggers 5x speed`

#### TDD Green
- `lib/platform/tv/remote_handler.dart`: 完整按鍵映射
- `lib/core/input/keyboard_handler.dart`: 統一 `RemoteButton` enum + `Intent` 映射
- `player_screen.dart`: Play/Pause/FastForward/Rewind/Next/Previous 按鍵處理

#### BDD Verify
`flutter test test/bdd/steps/input_steps.dart`

---

### 2.2 來源屏蔽

**Spec 來源**: `UI_UX.md §17.1`

#### TDD Red
```
test/features/settings/source_blocklist_test.dart  (new)
test/bdd/steps/settings_steps.dart  (extend)
```
Scenarios:
- `Scenario: User blocks a source then sees it filtered from list`
- `Scenario: Blocked source does not appear in auto-selection`

#### TDD Green
- `lib/core/source/source_blocklist.dart` (new) 或擴充 `source_selector.dart`
- `settings_store.dart`: `blockedSources: Set<String>`
- UI: `lib/features/settings/presentation/widgets/source_blocklist_card.dart`
- `luna_client.dart` / `source_selector.dart`: 過濾 blocked sources

#### BDD Verify
`flutter test test/features/settings/`

---

### 2.3 家長鎖

**Spec 來源**: `UI_UX.md §17.2`

#### TDD Red
```
test/features/settings/parental_lock_store_test.dart  (new)
test/bdd/steps/parental_lock_steps.dart  (extend)
test/features/detail/detail_parental_gate_test.dart  (extend)
```
Scenarios:
- `Scenario: Adult content hidden without PIN`
- `Scenario: Correct PIN unlocks parental control`
- `Scenario: Wrong PIN shows error`

#### TDD Green
- `lib/core/services/parental_control_service.dart`: PIN 驗證、lockout 邏輯
- `lib/features/settings/presentation/widgets/parental_lock_card.dart` (UI)
- `detail_screen.dart`: 成人內容需要 PIN 解鎖
- `parental_control_service_test.dart` 已存在 → 確保覆蓋邊界

#### BDD Verify
`flutter test test/bdd/steps/parental_lock_steps.dart`

---

### 2.4 TV Tab 順序拖曳

**Spec 來源**: `UI_UX.md §13.1` —「Tab 順序：調整 TV 頂部導航順序（拖曳）」

#### TDD Red
```
test/features/settings/tab_order_test.dart  (new)
test/bdd/steps/settings_steps.dart  (extend)
```

#### TDD Green
- `settings_store.dart`: `tabOrder: List<TabItem>` + SharedPreferences persistence
- `home_screen.dart` (TV): 讀取 `tabOrder` 動態渲染 TabBar
- UI: `ReorderableListView` 拖曳 UI

#### BDD Verify
`flutter test test/features/settings/tab_order_test.dart`

---

## Phase 3: P1/P2 收尾 — 直播增強 + UX 細節

### 3.1 直播：訊號異常 UI

**Spec 來源**: `UI_UX.md §9.7`

**現狀**: `signal_error_widget.dart` 存在，需確認是否完整。

#### TDD Red
```
test/features/live/signal_error_test.dart  (new)
test/bdd/steps/live_tv_steps.dart  (extend)
```

#### TDD Green
- `signal_error_widget.dart`: 補完 spec 的「訊號異常，請稍後重試」+ [重新整理] 按鈕
- `live_player_screen.dart`: 串接網路狀態

---

### 3.2 首頁區塊顯示開關

**Spec 來源**: `UI_UX.md §13.1` —「首頁區塊：開關各區塊顯示」

#### TDD Red
```
test/features/home/home_block_visibility_test.dart  (new)
test/bdd/steps/home_steps.dart  (extend)
```

#### TDD Green
- `settings_store.dart`: `homeBlockVisibility: Map<String, bool>`
- `home_screen.dart`: 根據 visibility 條件渲染各區塊

---

### 3.3 TV QR 輸入（手機掃碼輸入）

**Spec 來源**: `UI_UX.md §13.4`

**現狀**: `lib/shared/widgets/qr_input_widget.dart` + `core/services/local_http_server.dart` 已有基礎。

#### TDD Red
```
test/features/settings/qr_input_bdd_test.dart  (new)
test/bdd/steps/settings_steps.dart  (extend)
```
Scenarios:
- `Scenario: TV displays QR code for text input`
- `Scenario: Phone scans QR and sends input to TV`

#### TDD Green
- `qr_input_widget.dart`: 確認完整 flow (顯示 QR → local HTTP server 接收 → 寫入 target field)
- 可能需要補 `local_http_server.dart` 的 multi-field 支援

---

### 3.4 搜尋：語音搜尋

**Spec 來源**: `UI_UX.md §4.4`

**現狀**: `speech_to_text` dependency 已宣告。

#### TDD Red
```
test/features/search/voice_search_test.dart  (new)
test/bdd/steps/search_steps.dart  (extend)
```

#### TDD Green
- `search_screen.dart`: 麥克風按鈕 → speech_to_text → 自動填入 + 搜尋

---

## TDD 工作流程

```
每個 feature 遵循:

  1. Write a failing test  (Red)
     └── flutter test test/features/<x>/<x>_test.dart

  2. Write the minimum code to pass  (Green)
     └── flutter test test/features/<x>/<x>_test.dart  (must pass)

  3. Refactor  (Blue)
     └── flutter analyze
     └── flutter test (regression)
```

## BDD 驗證清單

| Feature | BDD Test File |
|---------|--------------|
| 主题切换 | `settings_theme_bdd_test.dart` (new) |
| 自動播放 | `player_steps.dart` (existing, extend) |
| TV 遙控器 | `input_steps.dart` (existing, extend) |
| 來源屏蔽 | `settings_steps.dart` (existing, extend) |
| 家長鎖 | `parental_lock_steps.dart` (existing, extend) |
| Tab 順序 | `settings_steps.dart` (extend) |
| 訊號異常 | `live_tv_steps.dart` (extend) |
| 首頁區塊開關 | `home_steps.dart` (extend) |
| QR 輸入 | `settings_steps.dart` (extend) |
| 語音搜尋 | `search_steps.dart` (extend) |

---

## 建議執行順序

```
Phase 1 (P0 缺口)
  1.1 主題切換        → 1-2 days
  1.2 自動播放下一集   → 1 day

Phase 2 (P1 TV+屏蔽)
  2.1 TV 遙控器       → 2-3 days
  2.2 來源屏蔽        → 1-2 days
  2.3 家長鎖          → 2 days
  2.4 Tab 拖曳        → 1 day

Phase 3 (P1/P2 收尾)
  3.1 訊號異常 UI     → 0.5 day
  3.2 首頁區塊開關    → 0.5 day
  3.3 QR 輸入         → 1 day
  3.4 語音搜尋        → 1 day
```

**Phase 1 → Phase 2 → Phase 3**，每 phase 內可平行開發獨立的 feature。
