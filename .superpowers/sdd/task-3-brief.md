# Task 3 Brief: 實作 TimeshiftClientBuffer

## 任務描述

建立 `TimeshiftClientBuffer` 用戶端時移緩存類別。

## 檔案

- Create: `lib/features/live/domain/services/timeshift_client_buffer.dart`
- Test: `test/features/live/domain/services/timeshift_client_buffer_test.dart`

## 介面

```dart
class TimeshiftClientBuffer {
  static const maxBufferDuration = Duration(minutes: 30);
  
  bool get isActive;
  String? get channelId;
  Duration get maxDuration;
  Duration get bufferedDuration;
  
  Future<void> start(String channelId, Duration duration);
  Future<void> stop();
}
```

## 提交訊息

```
feat(live): add TimeshiftClientBuffer for client-side timeshift fallback
```
