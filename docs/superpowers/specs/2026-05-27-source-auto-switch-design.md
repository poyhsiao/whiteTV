# 多來源自動切換功能設計規格

**版本**: v1.0
**日期**: 2026-05-27
**功能**: 多來源自動切換
**架構**: 依據 `docs/spec/ARCHITECTURE.md` v2.0 和 `docs/spec/UI_UX.md` v1.0
**狀態**: 已核准

---

## 1. 功能概述

當影片播放失敗時（超時或錯誤），系統自動切換到最快的可用來源，實現無縫繼續播放。

### 核心流程

```
播放失敗（超時/錯誤）
         │
         ▼
┌─────────────────────┐
│  SourceAutoSwitcher │
│  - retryCount < 2?  │
└─────────────────────┘
         │
         ├── 是 → 測速所有來源 → 選擇最快 → 切換 → 重試播放
         │
         └── 否 → 顯示錯誤提示（已切換 N 次仍失敗）
```

---

## 2. 架構設計

### 2.1 元件結構

```
lib/
├── features/
│   └── player/
│       ├── services/
│       │   └── source_auto_switcher.dart    # 自動切換邏輯
│       │   └── source_tester.dart          # 來源測速
│       ├── stores/
│       │   └── player_store.dart           # 播放器狀態
│       └── widgets/
│           └── player_controls.dart        # 控制項 UI
```

### 2.2 SourceAutoSwitcher 類

```dart
class SourceAutoSwitcher {
  final List<VideoSource> sources;
  final int maxRetries;

  int _retryCount = 0;
  VideoSource? _currentSource;

  // 當來源播放失敗時調用
  Future<SwitchResult> onSourceFailed({
    required VideoSource failedSource,
    required FailureReason reason, // timeout | error
  }) async {
    if (_retryCount >= maxRetries) {
      return SwitchResult.exhausted;
    }

    // 測速並排序
    final sortedSources = await _testAndSortSources();

    // 選擇下一個（排除當前失敗的）
    final nextSource = sortedSources
        .where((s) => s.id != failedSource.id)
        .firstOrNull;

    if (nextSource == null) {
      return SwitchResult.noSourceAvailable;
    }

    _retryCount++;
    _currentSource = nextSource;
    return SwitchResult.switched(source: nextSource);
  }

  void reset() {
    _retryCount = 0;
  }
}
```

### 2.3 SourceTester 類

```dart
class SourceTester {
  Future<List<SourceTestResult>> testAll(List<VideoSource> sources) async {
    final results = await Future.wait(
      sources.map((s) => testSpeed(s, timeout: 5.seconds)),
    );
    results.sort((a, b) => a.latency.compareTo(b.latency));
    return results;
  }

  Future<SourceTestResult> testSpeed(VideoSource source, {required Duration timeout}) async {
    final stopwatch = Stopwatch()..start();
    try {
      await _probeSource(source, timeout: timeout);
      stopwatch.stop();
      return SourceTestResult(source: source, latency: stopwatch.elapsedMilliseconds, available: true);
    } catch (_) {
      stopwatch.stop();
      return SourceTestResult(source: source, latency: -1, available: false);
    }
  }
}
```

---

## 3. 失敗檢測策略

### 3.1 失敗類型

| 類型 | 偵測方式 | 閾值 |
|------|----------|------|
| **超時** | 播放卡住超過 N 秒無資料 | 10 秒 |
| **錯誤碼** | 播放器回報錯誤事件 | any error |

### 3.2 實作方式

```dart
// 在 PlayerStore 中監聽播放狀態
void onPlaybackError(PlaybackError error) {
  final autoSwitcher = SourceAutoSwitcher(sources: currentSources);

  autoSwitcher.onSourceFailed(
    failedSource: currentSource,
    reason: error.isTimeout ? FailureReason.timeout : FailureReason.error,
  ).then((result) {
    if (result is SwitchResult.switched) {
      // 切換到新來源並重試
      switchToSource(result.source);
      play();
    } else {
      // 顯示錯誤提示
      showError('播放失敗，已嘗試所有來源');
    }
  });
}
```

---

## 4. 使用者體驗

### 4.1 無縫繼續

- 切換時不明顯提醒用戶
- 重試播放自動開始
- 用戶感覺「好像沒發生過」

### 4.2 重試限制

- 最多自動切換 2 次
- 2 次都失敗後顯示提示
- 用戶可手動選擇來源

### 4.3 UI 提示（最小化）

- 僅在最終失敗時顯示提示
- 不在切換過程中打扰用戶

---

## 5. 測試策略

### 5.1 單元測試

| 測試案例 | 預期行為 |
|----------|----------|
| `SourceAutoSwitcher.onSourceFailed_retryCountExceeded` | 返回 `exhausted` |
| `SourceAutoSwitcher.onSourceFailed_sortedByLatency` | 選擇最低延遲的來源 |
| `SourceAutoSwitcher.onSourceFailed_excludesFailed` | 不選擇當前失敗的來源 |
| `SourceTester.testAll_sortByLatency` | 返回按延遲排序的結果 |

### 5.2 集成測試

| 測試案例 | 場景 |
|----------|------|
| `player_source_auto_switch_test` | 播放失敗 → 自動切換 → 繼續播放 |
| `player_source_auto_switch_exhausted_test` | 2 次失敗後顯示錯誤 |

### 5.3 BDD 測試

```gherkin
Scenario: 來源 A 播放失敗，自動切換到來源 B
  Given 使用者正在觀看影片（來源 A）
  When 來源 A 播放失敗（超時）
  Then 系統自動切換到來源 B（最快的）
  And 播放繼續，用戶無感知

Scenario: 所有來源都失敗
  Given 使用者正在觀看影片
  When 所有來源都播放失敗
  Then 系統顯示錯誤提示
  And 提供手動選擇來源的選項
```

---

## 6. 依賴與順序

### 6.1 前置條件

- [ ] VideoSource 模型已存在
- [ ] 播放器基本功能已實作
- [ ] 來源選擇 UI（手動）已存在

### 6.2 實作順序

1. **Phase 1**: SourceTester 測速服務
2. **Phase 2**: SourceAutoSwitcher 自動切換邏輯
3. **Phase 3**: PlayerStore 集成
4. **Phase 4**: UI 錯誤提示
5. **Phase 5**: 測試覆蓋

---

## 7. 設計決策摘要

| 決策 | 選擇 | 原因 |
|------|------|------|
| 觸發時機 | 播放失敗時 | 使用者意圖明確 |
| 切換體驗 | 無縫繼續 | TV 用戶不喜歡打斷 |
| 失敗檢測 | 超時 + 錯誤碼 | 兩種失敗模式都需要 |
| 來源排序 | 每次測速選擇最快 | 網路狀況會變 |
| 重試限制 | 最多 2 次 | 避免無限循環 |

---

*文件狀態: 已核准，等待實作*