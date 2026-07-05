# Sprint 7.3 Provider Audit (2026-07-05)

**目的**: Sprint 6.3 DI_AUDIT 完成 dioProvider 後,做整體掃描,識別 Sprint 8+ 候選。
**方法**: `grep -rn "= [A-Z][A-Za-z]*()" lib/ | grep -v "_test.dart\|.g.dart"`
**產出**: 3 個高價值候選 + 8 個低優先級雜訊。

---

## ✅ 已完成 (Sprint 7.1)
- `DioProvider` → `lib/core/api/dio_provider.dart`

---

## 🟢 高價值候選 (Sprint 8+)

### 1. SourceSelector (lib/core/source/source_selector_provider.dart:9)
```dart
final sourceSelectorProvider = Provider<SourceSelector>((ref) {
  final selector = SourceSelector();           // 硬編碼
  _loadBlockedSources(selector);
  return selector;
});
```
**問題**: 測試時無法注入 mock,只能跑真實 `loadBlockedSources`(涉及 SharedPreferences)。
**候選**: 抽 `SourceSelectorFactory` 或 ref.watch 依賴 (`sharedPreferencesProvider`) + 在 test setUp override。
**工時**: 1-2 小時
**風險**: 中。`SourceSelector` 已有方法 level 抽象,只需抽 factory。

### 2. HttpClient (lib/core/source/source_selector.dart:88)
```dart
final client = HttpClient();                    // dart:io HttpClient
```
**問題**: 真實 IO 客戶端,測試時會打真網路。
**候選**: 抽出 `HttpClientFactory` 或接受 `Future<void> Function(Uri)>` 注入。
**工時**: 30 分鐘
**風險**: 低。呼叫點只有 `testSingleSource` 一處。

### 3. InputService (lib/features/login/presentation/screens/login_screen.dart:24, lib/features/settings/presentation/screens/input_screen.dart:28)
```dart
final InputService _inputService = InputService();
```
**問題**: 兩處 UI 直接 `new InputService()`,無注入點。
**候選**: 抽 `inputServiceProvider`,已有 `core/services/input_service.dart` 路徑。
**工時**: 30 分鐘
**風險**: 低。`InputService` 內部已是純 getter 邏輯 (Sprint 4.1 結論:純 getter 達極限)。

---

## 🟡 低優先級 (UI 內部 state,不值得抽)

| 位置 | 類別 | 說明 |
|------|------|------|
| `player_screen.dart:38,63` | `Player()`, `MediaKitPlayerController()` | MediaKit factory pattern,需由 plugin 決定 |
| `home_screen.desktop.dart:32` | `FocusNode()` | Flutter 內建 widget state |
| `keyboard_input_view.dart:35`, `detail_screen.dart:38`, `desktop_dock_navigation.dart:65` | `FocusNode()` | 同上 |
| `input_screen.dart:142`, `live_screen.dart:15`, `login_screen.dart:22-23`, `onboarding_screen.dart:14` | `TextEditingController()` | Flutter widget 生命週期內建 |
| `live_service.dart:128` | `StringBuffer()` | 純 utility |
| `source_selector.dart:106`, `luna_client.dart:106` | `Stopwatch()` | 純 utility (測量) |
| `input_service.dart:32`, `local_http_server.dart:32` | `Router()` | Shelf router factory |
| `voice_input_service.dart:13` | `SpeechToText()` | Plugin 無抽象介面 (Sprint 6.3 結論) |

**結論**: 這 8 項 UI state / utility 無 DI 投資報酬,跳過。

---

## 🟠 UI 平台外殼 (評估中)

- `home_screen.desktop.dart` 與 `keyboard_input_view.dart`/`qr_input_view.dart` 為 platform-specific UI,內部 `FocusNode()` 是 Flutter widget 慣例。
- `Player` / `MediaKitPlayerController`: MediaKit 已是公開 factory pattern,DI 只會增加複雜度。

---

## 建議 Sprint 8 順序

1. **InputServiceProvider** — 30 分鐘,跨 login/settings 兩個 widget,易於 TDD
2. **HttpClientFactory for SourceSelector** — 30 分鐘,單一呼叫點,易於 mock
3. **SourceSelector 依賴注入** — 1-2 小時,完整 DI,提升 test isolation

---

*文件版本: Sprint 7.3 audit draft — Sprint 8 候選已識別*