# Sprint 7 Plan

**產出時間**: 2026-07-04
**依據**: docs/spec/DI_AUDIT.md (Sprint 6.3)
**優先順序**: 1 (高價值)

---

## Sprint 7.1 DioProvider 統一管理

### 目標
跨模組統一 `Dio` instance 管理,從 3 個 hardcoded `new Dio()` 點改為注入式 Provider。

### 現況 (Sprint 6 audit)
1. `lib/providers/downloads_providers.dart:16` — `final dio = Dio();`
2. `lib/features/favorites/services/favorites_remote_service.dart:11` — `_dio = Dio(BaseOptions(...))` (已有 fromDio 替代)
3. 其他用 `createApiClient()` 創 Dio 的位置

### TDD 計畫

**紅階段**:
- 寫測試覆蓋「DioProvider 不存在 → createApiClient() 為 fallback」
- 寫測試覆蓋「注入 mock Dio → ProviderScope override 成功」

**綠階段**:
```dart
// lib/core/api/dio_provider.dart
final dioProvider = Provider<Dio>((ref) {
  throw UnimplementedError('dioProvider must be overridden');
});
```

**重構**: 各 service constructor 接收 Dio,Provider 改用 ref.watch(dioProvider)

### 預估工時
2-3 小時(含測試)

### 風險
- 既有 mock 用 `Dio(BaseOptions(...))` 直接 new,需全改 Provider override
- `createApiClient()` 多個 caller,需逐一改

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

1. **7.1 DioProvider** (高 ROI,跨模組)
2. **7.3 Provider Audit** (識別更多)
3. **7.2 AppRouter Smoke** (中等 ROI)

---

*文件版本: Sprint 7 plan draft — 待使用者過目後啟動*