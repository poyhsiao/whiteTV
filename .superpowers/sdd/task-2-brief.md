# Task 2 Brief: 實作 TimeshiftServiceAdapter

## 任務描述

建立 `TimeshiftServiceAdapter` 服務端時移適配器，串接 LunaTV API。

## 檔案

- Create: `lib/features/live/domain/services/timeshift_service_adapter.dart`
- Test: `test/features/live/domain/services/timeshift_service_adapter_test.dart`

## 介面

```dart
class TimeshiftServiceAdapter {
  TimeshiftServiceAdapter(this._apiClient);
  
  Future<bool> checkSupport(String channelId);
  Future<String?> getStream(String channelId, Duration startOffset, Duration endOffset);
}
```

## 實作要點

- 使用 `ApiClient` 來檢查服務端是否支援時移
- `getStream` 目前回傳 `null`（TODO，等待串接 LunaTV API）
- 遵循現有程式碼風格

## 提交訊息

```
feat(live): add TimeshiftServiceAdapter for service-side timeshift
```
