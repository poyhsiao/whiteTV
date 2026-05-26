# TDD 測試覆蓋率強化設計

**日期**: 2026-05-26
**專案**: whiteTV Flutter
**目標**: 強化 Store 層測試覆蓋率至 80%+

---

## 1. 概述

根據 ARCHITECTURE.md 和 UI_UX.md 的功能規劃，當前 whiteTV 的 Store 層測試覆蓋率不足。本設計提出全面的 TDD 測試強化方案，確保所有 Store 方法都有充分的單元測試和 BDD 整合測試覆蓋。

## 2. 現狀分析

### 測試覆蓋率矩陣

| Store | 現有測試數 | 覆蓋方法 | 未測方法 | 缺口级别 |
|-------|-----------|---------|---------|----------|
| HomeStore | ~4 | loadHome | setHistoryService, 邊界情况 | 高 |
| DetailStore | ~4 | loadDetail, selectSource | selectEpisode, 錯誤路徑 | 高 |
| HistoryStore | ~5 | 部分覆蓋 | loadHistory, deleteRecord | 中 |
| SearchStore | ~9 | 核心流程 | 錯誤處理邊界 | 中 |
| LiveStore | ~10 | 多數覆蓋 | clearSignalError, searchChannels | 低 |
| PlayerStore | ~11 | 良好 | 邊界情况 | 低 |

### 缺口原因

1. **HomeStore**: `setHistoryService` 在構造後注入，但無測試驗證
2. **DetailStore**: `selectEpisode` 涉及集數切換邏輯未測
3. **HistoryStore**: 刪除記錄的並發场景未覆蓋
4. **SearchStore**: API 錯誤時的降级邏輯未完整測試
5. **LiveStore**: 信號錯誤清除和頻道搜尋未測
6. **PlayerStore**: 來源切換的自動切換計數边界未測

---

## 3. 強化方案

### 3.1 測試策略

遵循 TDD 流程：
1. **RED** — 為每個未測方法撰寫失敗測試
2. **GREEN** — 運行測試驗證現有實作（如需要小幅度修正）
3. **IMPROVE** — 重構測試結構，確保可維護性

### 3.2 測試類型

| 類型 | 適用場景 | 工具 |
|------|---------|------|
| 單元測試 | Store 方法隔離測試 | flutter_test |
| BDD 整合測試 | 跨 Service 協作驗證 | 現有 BDD 框架 |
| 邊界測試 | 空資料、錯誤、超時 | Fake/Mock |

### 3.3 優先順序

按現有測試數量從少到多排序：

1. **HomeStore** (+8-12 tests)
2. **DetailStore** (+10-15 tests)
3. **HistoryStore** (+8-12 tests)
4. **SearchStore** (+6-10 tests)
5. **LiveStore** (+4-6 tests)
6. **PlayerStore** (+5-8 tests)

---

## 4. 各 Store 測試規劃

### 4.1 HomeStore

**未測方法**:
- `setHistoryService()` — 構造後注入驗證
- `clearHome()` — 狀態清除
- `refreshHome()` — 重新整理逻辑

**新增測試場景**:
```dart
group('HomeStore - setHistoryService', () {
  test('should update historyService reference', () {
    // Arrange
    final store = HomeStore();
    final mockService = FakeHistoryService();

    // Act
    store.setHistoryService(mockService);

    // Assert
    expect(store.historyService, equals(mockService));
  });
});
```

### 4.2 DetailStore

**未測方法**:
- `selectEpisode()` — 集數選擇逻辑
- `toggleFavorite()` — 收藏切換
- `loadEpisodes()` — 集數列表加载

**新增測試場景**:
```dart
group('DetailStore - selectEpisode', () {
  test('should update currentEpisode when valid index', () {
    // Arrange
    final store = DetailStore();
    store.episodes = [Episode(id: '1'), Episode(id: '2')];

    // Act
    store.selectEpisode(1);

    // Assert
    expect(store.currentEpisode?.id, equals('2'));
  });

  test('should not crash on invalid index', () {
    // Arrange
    final store = DetailStore();
    store.episodes = [Episode(id: '1')];

    // Act & Assert
    expect(() => store.selectEpisode(99), returnsNormally);
  });
});
```

### 4.3 HistoryStore

**未測方法**:
- `loadHistory()` — 歷史記錄加載
- `deleteRecord()` — 刪除單筆記錄
- `mergeRemoteHistory()` — 合併遠端歷史

**新增測試場景**:
```dart
group('HistoryStore - deleteRecord', () {
  test('should remove record from local storage', () async {
    // Arrange
    final store = HistoryStore();
    await store.loadHistory();
    final initialCount = store.records.length;

    // Act
    await store.deleteRecord('record-1');

    // Assert
    expect(store.records.length, equals(initialCount - 1));
    expect(store.records.any((r) => r.id == 'record-1'), isFalse);
  });
});
```

### 4.4 SearchStore

**未測方法**:
- `cancelSearch()` — 取消搜尋
- `loadMoreResults()` — 載入更多結果
- `clearFilters()` — 清除篩選

**新增測試場景**:
```dart
group('SearchStore - cancelSearch', () {
  test('should stop ongoing search and reset loading', () async {
    // Arrange
    final store = SearchStore();
    final searchFuture = store.search('test');

    // Act
    await store.cancelSearch();

    // Assert
    expect(store.isLoading, isFalse);
  });
});
```

### 4.5 LiveStore

**未測方法**:
- `clearSignalError()` — 清除信號錯誤
- `searchChannels(query)` — 搜尋頻道

**新增測試場景**:
```dart
group('LiveStore - clearSignalError', () {
  test('should reset signalError state', () {
    // Arrange
    final store = LiveStore();
    store.handleSignalError('Weak signal');

    // Act
    store.clearSignalError();

    // Assert
    expect(store.signalError, isNull);
  });
});
```

### 4.6 PlayerStore

**未測方法**:
- `autoSwitchCount` 边界
- `saveProgress()` 並發

**新增測試場景**:
```dart
group('PlayerStore - autoSwitchCount', () {
  test('should respect max auto switch limit', () {
    // Arrange
    final store = PlayerStore();
    store.autoSwitchCount = 3;
    store.maxAutoSwitch = 3;

    // Act
    store.incrementAutoSwitch();

    // Assert
    expect(store.autoSwitchCount, equals(3));
    expect(store.canAutoSwitch, isFalse);
  });
});
```

---

## 5. 驗證標準

### 5.1 TDD 流程驗證

- [ ] 每個新測試先 RED（預期失敗）
- [ ] 測試描述清楚表達預期行為
- [ ] 所有測試通過 GREEN
- [ ] 測試覆蓋率達到 80%+

### 5.2 BDD 驗證

使用 Gherkin 語法驗證關鍵流程：
```gherkin
Feature: History Management
  Scenario: Delete single record
    Given history has 5 records
    When user deletes record "record-3"
    Then history should have 4 records
    And record "record-3" should not appear
```

### 5.3 測試質量標準

- [ ] 每個測試独立運行（無順序依賴）
- [ ] 使用 Fake/Mock 而非真實 Service
- [ ] 測試名清楚描述場景
- [ ] 錯誤消息有意義

---

## 6. 實施計劃

### Phase 1: HomeStore + DetailStore (高缺口)
- 補寫 18-27 個測試
- 驗證 Store 方法覆蓋

### Phase 2: HistoryStore + SearchStore (中缺口)
- 補寫 14-22 個測試
- BDD 整合驗證

### Phase 3: LiveStore + PlayerStore (低缺口)
- 補寫 9-14 個測試
- 完成最終覆蓋驗證

---

## 7. 風險與緩解

| 風險 | 緩解方案 |
|------|---------|
| 現有測試失敗 | 先修復再擴展 |
| Store 方法依賴未定義 | 使用 Fake 注入 |
| 邊界情况模擬困難 | 使用狀態機模型 |

---

*文件状态: draft — 待用户審查後執行*