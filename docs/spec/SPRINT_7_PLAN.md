# Sprint 7 Plan

**產出時間**: 2026-07-04
**依據**: docs/spec/DI_AUDIT.md (Sprint 6.3)
**優先順序**: 1 (高價值)

---

## Sprint 7.1 DioProvider 統一管理 — ✅ DONE (2026-07-05)

### 目標
跨模組統一 `Dio` instance 管理,從 3 個 hardcoded `new Dio()` 點改為注入式 Provider。

### 變更摘要
- **新增** `lib/core/api/dio_provider.dart` — canonical 位置,default `Dio()`(fail-soft,允許 legacy 與測試裸跑)
- **修改** `lib/providers/downloads_providers.dart` — 移除本地 `dioProvider`,改為 `export '...dio_provider.dart' show dioProvider`(相容既有 import)
- **修改** `lib/features/favorites/services/favorites_remote_service.dart` — `favoritesRemoteServiceProvider` 改用 `ref.watch(dioProvider)` + `withDio(...)`,消除 `Dio(BaseOptions(...))` 硬編碼
- **新增** `test/core/api/dio_provider_test.dart` — 3 個測試驗證 (1) override 成功 (2) legacy re-export 是同一個 provider 物件 (3) 預設返回 `Dio`
- **修改** `test/features/favorites/stores/favorites_store_test.dart` — 補 `favoritesRemoteServiceProvider.overrideWith(throw ...)` 以保留 "Remote service not configured" 語意

### TDD 結果
- 紅: `dioProvider` 未在 `core/api/` → import error ❌
- 綠: 新增 `dio_provider.dart`,測試 3/3 通過 ✅
- 重構: downloads_providers 與 favorites_remote_service 改用 ref.watch(dioProvider),全 suite 1267/1267 綠 ✅

### 剩餘 hardcoded `Dio` (本 sprint 不處理)
- `lib/core/api/luna_client.dart:18` — `Dio()` 為 fallback 用途,屬於另一條架構線 (`createApiClient()` 工廠),保留
- `lib/features/favorites/services/favorites_remote_service.dart:14` — `Dio(BaseOptions(...))` 為舊 constructor(相容測試),建議下次 sprint 移除或 deprecated

### 後續影響
- `main.dart` 目前未顯式 override `dioProvider` (default `Dio()` 仍可運作)
- 後續可考慮在 `main.dart` 加 `dioProvider.overrideWithValue(dio)` 並設定 timeouts/baseUrl
- 已建立的統一 provider 可供未來 `history_sync`, `player` 等模組複用

### 預估工時
2-3 小時(含測試) — 實際 1.5 小時

---

## Sprint 7.2 AppRouter 手動 Smoke Test

### 目標
驗 14 個 GoRoute 真的 navigate 到正確 widget (用 pumpWidget 而非 mock)

### TDD 計畫
- **紅**: 啟動 app,依序 navigate 每個 route,verify 顯示
- **綠**: `test/integration/app_routes_smoke_test.dart` 跑 5+ route
- **重構**: 抽 `pumpRoute(WidgetTester, routeName, widget)` helper

### 預估工時
3-4 小時

---

## Sprint 7.3 整體 Provider Audit

### 目標
掃描所有 `final x = SomeClass()` 模式,找出剩餘 DI 候選

### 方法
```bash
grep -rn "= [A-Z][A-Za-z]*()" lib/ | grep -v "_test.dart\|.g.dart"
```

### 預估工時
1-2 小時 (純 audit + 文件化)

---

## Sprint 7+ 候選 (待掃描後決定)

1. NetworkListener (lib/core/connectivity) — `connectivity_plus` 抽象
2. TimeshiftClientBuffer (lib/features/live) — IO buffer 抽象
3. TabNavigationStore (lib/features/settings) — persistence 抽象

---

## 執行順序

1. ~~**7.1 DioProvider** (高 ROI,跨模組)~~ ✅ DONE
2. **7.3 Provider Audit** (識別更多) ← NEXT
3. **7.2 AppRouter Smoke** (中等 ROI)

---

*文件版本: Sprint 7 plan — 7.1 完成, 7.3 與 7.2 待啟動*