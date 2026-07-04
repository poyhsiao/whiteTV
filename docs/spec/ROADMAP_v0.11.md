# whiteTV v0.11+ 待調整項目規格變更 (TDD + BDD)

**版本**: v0.11.x 路線圖
**產出時間**: 2026-07-03
**工作流**: TDD (紅→綠→重構) + BDD (Given/When/Then)
**參考**: ARCHITECTURE.md, UI_UX.md, CHANGELOG.md (目前 v0.10.8)

---

## 0. 盤點方法

比對規範 (`docs/spec/ARCHITECTURE.md`, `docs/spec/UI_UX.md`) 與現有程式碼 (`lib/`, `test/`)。
每個項目列出：規範章節 / 現況 / 缺口類型 / 預估 TDD 起步動作。

---

## 1. 已完成項目 (v0.8 ~ v0.10) — 不需重做

| 模組 | 狀態 | 對應版本 |
|------|------|----------|
| Home 首頁 + AI 推薦區塊 | ✅ 完成 | v0.9, v0.10.0 |
| Onboarding 3 步流程 | ✅ 完成 | v0.9 |
| 來源切換器 (SourceSelector + 測速 + 屏蔽) | ✅ 完成 | v0.7+, lib/core/source/ |
| 影片詳情頁 (TV vertical list / mobile chip) | ✅ 完成 | v0.10.0 |
| Player 控制列 + 鎖定 + 來源熱切換 | ✅ 完成 | v0.10.0, v0.10.3 |
| Timeshift (serviceSide + clientBuffer) | ✅ 完成 | v0.10.3 |
| 收藏 + 跨設備同步 | ✅ 完成 | v0.8.3 |
| 歷史 + 繼續觀看 | ✅ 完成 | v0.8.3, lib/features/history/widgets/recent_watch_section.dart |
| 設定頁 (登入/家長鎖/主題/首頁區塊/Tab 排序) | ✅ 完成 | v0.9, v0.10.0 |
| 家長鎖 (PIN + Lockout) | ✅ 完成 | v0.9 |
| 登入流程 | ✅ 完成 | v0.9 |
| 搜尋 + 即時搜尋 + 語音 | ✅ 完成 (speech_to_text 已整合) |
| Live TV (IPTV JSON/M3U + EPG + 時移 + 靜音過渡) | ✅ 完成 | v0.8.1, v0.10.3 |
| Tab 自訂 (拖曳排序) | ✅ 完成 | v0.10.3 |
| iOS Handoff + PiP Platform Channel | ✅ 完成 | v0.10.2 |
| QR Code 輸入 (mobile_scanner + qr_flutter) | ✅ 完成 | lib/features/search/widgets/qr_input_view.dart |
| 下載服務 (DownloadService + DownloadsStore) | ⚠ 部分 | 見 §3.1 |
| 分類瀏覽 (TV chips + Mobile 折疊) | ⚠ 部分 | 見 §3.2 |
| AI 推薦 (雙軌策略) | ✅ 完成 | v0.8.3 |
| 空狀態元件 (EmptyStateWidget) | ✅ 完成 | v0.9 |
| 骨架屏 (SkeletonLoader) | ✅ 完成 | v0.9 |

---

## 2. 規範明確要求但**完全未實作**

### 2.1 繼續觀看進度同步 (Continue Watching Sync)
- **規範**: UI_UX.md §6 歷史記錄功能 + 規範細項 (跨設備同步)
- **現況**: ✅ 已實作 `HistoryService.syncFromRemote()` merge 策略
  - 用 `lastWatched` timestamp 比較,本地較新或相等時保留本地並同步到遠端
  - 遠端較新時覆寫本地
  - 缺本地記錄時直接寫入
- **已交付**:
  - `lib/features/history/services/history_service.dart` — merge 邏輯
  - `test/features/history/history_sync_merge_test.dart` — 3 個情境 + 1 個邊界測試 (時間戳相等)

### 2.2 全域返回鍵 (TV `Back` 行為)
- **規範**: UI_UX.md §15.1 TV 遙控器全按鍵對應:`Back` → 返回上一頁/關閉對話框
- **現況**: ✅ 已實作 `BackConfirmation` widget
  - TV 首頁按 `Back` → 顯示 SnackBar「再按一次退出 whiteTV」
  - 2 秒內再按第二次觸發 `onConfirmExit` (`SystemNavigator.pop()`)
  - 使用 `PopScope` + Timer 實作,非根路由可正常 pop
- **已交付**:
  - `lib/shared/widgets/back_confirmation.dart` — 可复用 widget
  - `lib/features/home/home_screen.dart` — TV 平台整合
  - `test/widget/back_confirmation_test.dart` — 3 個 widget test

### 2.3 QR Remote (TV 掃碼輸入 — 不同於 QR 掃碼輸入)
- **規範**: UI_UX.md §9.4 TV 模式:手機掃碼輸入 — TV 顯示 QR Code,**手機掃碼後手機開網頁輸入即時傳到 TV**
- **現況**: `QRInputView` 是 mobile_scanner,只實作「掃碼」,**沒有「顯示 QR Code 讓手機掃」的對向**
- **缺口**: TV 端需 server (shelf 已依賴) 顯示 QR Code + websocket,即時接收 mobile 輸入
- **TDD 起步**:
  - 紅: `QRSessionServer` unit test — 啟動後產生 session id + QR payload (含 URL)
  - 綠: shelf handler 接收 `/input?session=xxx&text=yyy`,推入 broadcast stream
  - 重構: 抽 `RemoteInputChannel` interface,實作 WebSocketChannel
- **BDD**: test/bdd/features/unified_input_system.feature 加 scenario「TV 顯示 QR,手機掃碼輸入同步到 TV」

---

## 3. 已實作骨架但**未完成/薄弱**

### 3.1 下載管理 (Downloads) ⚠ 待加強
- **規範**: UI_UX.md §13.1 設定項「影片品質」、「自動播放」(無獨立下載章節);隱含需求:離線播放
- **現況**:
  - `DownloadService` (lib/features/player/services/download_service.dart) 存在
  - `DownloadsStore` 邏輯完整
  - **問題**: BDD feature 寫了 6 個 scenario,實際測試只找到 3 個 unit test
- **缺口**:
  - **3.1.a** 缺整合測試:`test/features/downloads/` 只有 store 單元測,沒有 BDD step def
  - **3.1.b** 缺 UI:有 `DownloadsScreen` 但需驗證 6 個 BDD scenario 是否真的能跑通
- **TDD 起步**:
  - 紅: 對應 `test/bdd/features/downloads.feature` 6 個 scenario 的 step def 寫齊
  - 紅: 對 `DownloadService` 加 `getStorageStats()` 測試(已下載總大小)
  - 綠: 補 step implementation
- **BDD**: `test/bdd/steps/download_steps.dart` 已有 5.6K 內容,需驗證是否涵蓋所有 scenario

### 3.2 分類瀏覽 (Category) ⚠ 部分
- **規範**: UI_UX.md §7 TV/Mobile 雙模式 + 二級分類 + 地區 + 年份 + 排序
- **現況**: CategoryScreen + CategoryContentStore + CategoryConstants 已實作
- **缺口**:
  - **3.2.a** 不確定是否實作排序 (最近更新/評分/播放量/字母) 5 種
  - **3.2.b** 不確定地區/年份是否真的接 LunaTV API
- **TDD 起步**:
  - 紅: widget test `切換排序為「評分」後 API 帶 sort=rating`
  - 綠: CategoryContentStore 暴露 sortBy setter,傳給 API 呼叫
  - 重構: 抽 `CategoryFilterController`
- **BDD**: test/bdd/features/category_browsing.feature 已存在 — 驗證所有 step defs 是否實作

### 3.3 YouTube 整合 ⚠ 部分
- **規範**: ARCHITECTURE.md §5.1 P2 YouTube 整合
- **現況**: `YoutubeStore` + `youtube_player_iframe` ^6.0.2 已依賴
- **缺口**: 不確定實際功能 (首頁嵌入?獨立 Tab?)
- **TDD 起步**:
  - 紅: `test/features/youtube/youtube_store_test.dart` 驗 `loadRecommend()` 從 API 拿 video id list
  - 綠: 補 store logic 若缺失
  - 重構: 確認 youtube_player_iframe 與設定頁整合

### 3.4 推薦理由透明度 (AIRecommend Reason) ⚠ 未驗證
- **規範**: UI_UX.md §12 相關推薦 — 顯示推薦理由
- **現況**: `RecommendationReasonSheet` widget 存在 (lib/features/recommend/presentation/widgets/)
- **缺口**: 未確認是否真實接 `AIRecommendation.reason` 欄位
- **TDD 起步**: widget test 點擊卡片 → 顯示 reason sheet → 確認文字渲染

---

## 4. 規範未明確要求但**實務必要** (建議補)

### 4.1 設定頁「自動播放下一集」
- **規範**: UI_UX.md §13.1 列為設定項
- **現況**: 不確定是否實作
- **TDD 起步**: SettingsStore 加 autoPlayNext,Player 結束時檢查

### 4.2 設定頁「影片品質預設」
- **規範**: UI_UX.md §13.1
- **現況**: 不確定
- **TDD 起步**: 檢查 player 啟動時讀 settings.videoQuality

### 4.3 設定頁「來源選擇 (自動/手動)」
- **規範**: UI_UX.md §13.1 已列
- **現況**: 有 `sourceSelectorProvider` 預設自動;**設定頁切換開關** 待驗證
- **TDD 起步**: 寫 widget test 切換設定 → 驗證 SourceSelector 行為

### 4.4 來源快取清理
- **規範**: 無明確,但 `SourceSelector.cacheMaxAge = 30 min` 已硬編碼
- **建議**: 加設定項讓使用者調整保留時間 (P3)

---

## 5. TDD + BDD 雙軌開發流程 (本路線圖統一採用)

### 5.1 單元/整合層 TDD
每個項目:
1. **紅**: 先寫失敗測試 (紅),確認失敗原因合理 (NotImplemented / wrong behavior)
2. **綠**: 寫最小實作讓測試通過
3. **重構**: 消除重複、改善命名、必要時抽 interface
4. **驗證**: `flutter test` 全綠

### 5.2 行為層 BDD
每個 user-facing feature:
1. 寫 / 補 `test/bdd/features/*.feature` scenarios (Given/When/Then)
2. 對應 `test/bdd/steps/*_steps.dart` step definitions
3. 跑 `flutter test test/bdd/` 確認整體行為

### 5.3 測試金字塔原則
- 優先 BDD (行為) → TDD (單元) → widget test (UI)
- 避免過度細粒度, 只對**有邏輯分支 / 多路徑決策**的程式寫測試
- POC 程式碼不需要測試,但 ship 前必須有 happy path 測試

---

## 6. 建議 v0.11 衝刺順序 (依商業價值 + 依賴性)

### Sprint 1 (1-2 週): 修正 + 加固
- **§3.1.a** Downloads 補 BDD step defs + 整合測試
- **§3.2.a** Category 排序 5 種全部驗證
- **§2.2** TV 全域 `Back` 鍵處理 (小但必要)

### Sprint 2 (2-3 週): 完成 P1 缺口
- **§2.1** 繼續觀看跨設備同步邏輯釐清 + TDD
- **§3.4** AIRecommend Reason 驗證
- **§3.3** YouTube 整合釐清

### Sprint 3 (2-3 週): 高價值新功能
- **§2.3** QR Remote (TV ↔ Mobile 即時輸入) — 需要後端 shelf service
- **§4.1-4.3** 設定頁補齊

### Sprint 4 (持續): 已完成功能硬化
- 跑 coverage report 找出低覆蓋率模組,補測試
- 跑 `dart analyze --fatal-infos --fatal-warnings`
- 跑 `flutter test --coverage` 報告

---

## 7. 待你確認的開放問題

請回答後我才開始動 TDD:

### Q1. 優先順序
你希望從哪個 sprint 開始?
- A: Sprint 1 (Downloads / Category / Back 鍵) ← 建議,風險最低
- B: Sprint 2 (跨設備同步 / AIRecommend / YouTube)
- C: Sprint 3 (QR Remote — 工作量最大但最獨特)

### Q2. 測試覆蓋率目標
- A: 守住現有覆蓋率,只對新功能 TDD
- B: 新功能 80%+,舊模組補到 60%+
- C: 全模組補到 80%+ (工作量極大)

### Q3. BDD scenario 數量
- A: 現有 19 個 feature 全部補齊 step def (保守)
- B: 補齊 + 新增剩餘規範 scenario (中)
- C: 大量新增 (包括錯誤處理/邊界) (激進)

### Q4. LunaTV API 探索
- A: 我會用 mock LunaTV API 開發,不需真的 server
- B: 你會提供 LunaTV server URL,我做整合測試
- C: 兩者並行,CI 用 mock,本地可切真 server

---

*文件版本: v0.11.draft — 待使用者過目後轉為正式版*
