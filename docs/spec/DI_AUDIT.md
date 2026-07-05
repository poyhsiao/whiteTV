# whiteTV DI Audit (Sprint 6.3)

**產出時間**: 2026-07-04
**目的**: 掃描所有 hardcoded platform dependency,作為 Sprint 7+ 候選清單
**方法**: `grep -rn "= SpeechToText()|= Dio(|= FlutterSecureStorage()" lib/`

---

## 已完成 DI Refactor (Sprint 5)

| Module | Factory | 覆蓋率改善 |
|--------|---------|-----------|
| `FavoritesRemoteService` | `fromDio(Dio)` | 12% → 90% |
| `TVVoiceInputService` | `fromSpeech(SpeechController)` | 28% → 70% |

---

## 剩餘 Hardcoded Dependencies

### 1. `lib/providers/downloads_providers.dart:16`
```dart
final dio = Dio();
```
**問題**: Provider 內硬編碼 Dio,無法注入 mock
**Sprint 7+ 候選**: 抽 `DioProvider`,downloadsStoreProvider watch 它

### 2. `lib/features/favorites/services/favorites_remote_service.dart:11`
```dart
: _dio = Dio(BaseOptions(...))
```
**狀態**: 已有 fromDio 替代,但 baseUrl 建構子仍硬編碼
**Sprint 7+ 候選**: Provider 改用 fromDio 路徑

### 3. `lib/features/search/services/voice_input_service.dart:29`
```dart
final SpeechToText _speech = SpeechToText();
```
**限制**: SpeechToText 無 plugin 抽象介面,70% 為合理極限
**結論**: 不建議再抽象

---

## 跳過建議 (低投資報酬)

### AppRouter Builders (Sprint 6.2)
- 14 個 builder widget test 各需複雜 Riverpod override
- 工作量 ~4-6 小時,收益有限
- 改用手動 integration test 或實際 UI walk-through

---

## Sprint 7+ 候選優先順序

1. **DioProvider 統一管理** (Sprint 7.1) — 高價值,跨 3+ 模組
2. **AppRouter manual smoke test** (Sprint 7.2) — 手動驗證,不寫 code
3. **Riverpod Provider 整體 audit** (Sprint 7.3) — 找更多硬編碼 new 點

---

## 結論

Sprint 6 不建議再大規模重構。Sprint 7 應聚焦:
- 統一 Dio provider (跨模組價值)
- Manual smoke test (成本低)
- 整體 Provider audit