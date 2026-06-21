# Task 1 Brief: 擴展 TimeshiftManager 介面

## 任務描述

擴展現有的 `TimeshiftManager` 介面，新增服務端時移和用戶端緩存相關方法。

## 檔案

- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`
- Test: `test/features/live/domain/repositories/timeshift_manager_test.dart`

## 介面變更

在 `TimeshiftManager` 介面新增以下方法：

```dart
Future<bool> isServiceSideSupported(String channelId);
Future<String?> getServiceSideStream(
  String channelId,
  Duration startOffset,
  Duration endOffset,
);
Future<void> startClientBuffer(String channelId, Duration duration);
Future<void> stopClientBuffer();
```

## 提交訊息

```
feat(live): extend TimeshiftManager with service-side and client buffer methods
```
