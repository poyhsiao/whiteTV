# 播放器控制項完整實作設計

**日期**: 2026-05-31
**版本**: v1.0
**狀態**: 已核准

---

## 1. 概述

實作 whiteTV 播放器缺少的 6 個控制項（上一集/下一集、音量控制、集數選擇、來源選擇、全螢幕、設定），並確保所有控制項支援 TV remote 和 Mobile touch 操作。

**參考規格**: UI_UX.md Section 11.2, Section 15-16

---

## 2. 現有狀態

| 控制項 | 狀態 |
|--------|------|
| 播放/暫停 | ✅已有 |
| 進度條 | ✅ 已有 |
| 播放速度 | ✅ 已有 |
| 上一集/下一集 | ❌ 缺少 |
| 音量控制 | ❌ 缺少 |
| 集數選擇 | ❌ 缺少 |
| 來源選擇 | ❌ 缺少 |
| 全螢幕 | ❌ 缺少 |
| 設定 | ❌ 缺少 |

---

## 3. 架構

```
PlayerScreen
├── _buildTVControls() # TV remote 控制面板
├── _buildMobileControls()   # Mobile touch 控制面板
├── _buildControlBar()      # 通用控制欄
├── _buildVolumeSlider()     # 音量控制
├── _buildEpisodeSelector() # 集數選擇
├── _buildSourceSwitcher()  # 來源切換
├── _buildSpeedSelector()   # 播放速度（已有）
├── _buildFullscreenToggle() # 全螢幕切換
└── _buildSettingsPanel()   # 設定面板（字幕、音效）
```

**設計原則：**
- TV 和 Mobile 分開實作（使用 `_buildTVControls()` vs `_buildMobileControls()`）
- 所有控制項都支援 TV remote（D-pad 導航）
- 控制欄閒置 3-5 秒後自動隱藏

---

## 4. 控制項實作細節

### 4.1 上一集/下一集

| 平台 | 實作方式 |
|------|----------|
| TV | D-pad left/right 按鈕，聚焦時顯示 |
| Mobile | 滑動手勢（左右滑動切換集數） |

**行為：**
- 上一集：切換到前一集（若為第1集則提示「已是第一集」）
- 下一集：切換到下一集（支援自動播放下一集設定）

### 4.2 音量控制

| 平台 | 實作方式 |
|------|----------|
| TV | D-pad up/down + 靜音按鈕 |
| Mobile | 垂直滑動手勢 +靜音按鈕 |

**行為：**
- 音量範圍：0.0 - 1.0
- 靜音切換：點擊靜音按鈕
- 顯示音量百分比 Tooltip

### 4.3 集數選擇

| 平台 | 實作方式 |
|------|----------|
| TV | 遙控器 OK 彈出集數列表（GridView） |
| Mobile | 點擊按鈕彈出集數列表（ListView） |

**行為：**
- 顯示總集數和當前集數
- 支援 D-pad 導航選擇
- 選擇後自動播放該集

### 4.4 來源選擇

| 平台 | 實作方式 |
|------|----------|
| TV | 遙控器 OK 彈出來源列表（不含下拉選單） |
| Mobile | 點擊下拉選擇 |

**行為：**
- 顯示來源名稱、延遲時間（ms）、集數
- 當前自動選擇的來源標記 `[自動]`
-熱切換不中斷播放

### 4.5 全螢幕

| 平台 | 實作方式 |
|------|----------|
| TV | Menu 按鈕切換 |
| Mobile | 雙擊或按鈕 |

**行為：**
- 切換全螢幕/退出全螢幕
- TV模式下隱藏系統 UI

### 4.6 設定面板

| 平台 | 實作方式 |
|------|----------|
| TV | 遙控器 Menu 長按 |
| Mobile | 點擊設定按鈕 |

**行為：**
- 字幕設定（語言、切換）
- 音效設定（音軌）
- 播放設定（畫質）

---

## 5. 狀態管理（Riverpod）

```dart
// player_store.dart 新增 provider
final playerControlsVisibilityProvider = StateProvider<bool>((ref) => true);
final playerVolumeProvider = StateProvider<double>((ref) => 1.0);
final playerMutedProvider = StateProvider<bool>((ref) => false);
final playerFullscreenProvider = StateProvider<bool>((ref) => false);
final playerCurrentEpisodeProvider = StateProvider<int>((ref) => 1);
final playerCurrentSourceProvider = StateProvider<String?>((ref) => null);
```

---

## 6. TV Remote 按鍵對應

| 按鍵 | 動作 |
|------|------|
| D-pad 上/下 | 音量控制 |
| D-pad 左/右 | 上一集/下一集 或進度控制 |
| OK | 播放/暫停 或 確認選擇 |
| Play/Pause | 播放或暫停 |
| Fast Forward | 快進 10 秒 |
| Rewind | 快退 10 秒 |
| Menu | 全螢幕切換 或開啟設定 |
| Info | 顯示/隱藏播放資訊 |

---

## 7. 控制欄自動隱藏

-閒置 5 秒後自動隱藏底部控制欄
- 點擊畫面任一處顯示控制欄
- 鎖定按鈕可讓控制欄持續顯示

---

## 8. 預定產出檔案

```
lib/features/player/
├── player_screen.dart           # 主播放器（修改）
├── player_store.dart            # 狀態管理（修改）
├── widgets/
│   ├── player_control_bar.dart  # 通用控制欄
│   ├── volume_slider.dart        # 音量控制
│   ├── episode_selector.dart     # 集數選擇
│   ├── source_switcher.dart      # 來源切換
│   ├── fullscreen_toggle.dart   # 全螢幕
│   └── settings_panel.dart      # 設定面板
└── test/
    ├── player_store_test.dart   # 狀態管理測試
    ├── volume_slider_test.dart  # 音量控制測試
    ├── episode_selector_test.dart # 集數選擇測試
    └── player_controls_widget_test.dart # 控制項 UI 測試
```

---

## 9. TDD 測試策略

### Unit Tests
- `player_store_test.dart` - 測試各控制項狀態邏輯
- `player_controls_test.dart` - 測試控制項顯示/隱藏邏輯

### Widget Tests
- `player_controls_widget_test.dart` - 測試各控制項 UI 渲染
- `episode_selector_test.dart` - 測試集數選擇器
- `volume_slider_test.dart` - 測試音量控制

### BDD Tests
- `player_playback.feature` - 播放流程
- `player_controls.feature` - 控制項操作

---

## 10. 依賴

- Riverpod（已有）
- media_kit（已有）
- GoRouter（已有）

---

## 11. 實作順序

1. **階段一**：PlayerStore 新增 providers
2. **階段二**：上一集/下一集 +集數選擇
3. **階段三**：音量控制
4. **階段四**：來源選擇
5. **階段五**：全螢幕 +設定面板
6. **階段六**：TV Remote 整合
7. **階段七**：測試覆蓋率驗證

---

*文件版本: v1.0 — 播放器控制項完整實作設計*
