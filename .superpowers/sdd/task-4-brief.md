# Task 4 Brief: 更新 TimeshiftControlBar UI

## 任務描述

增強 TimeshiftControlBar widget，支援新的 TimeshiftMode 枚舉（live/service/buffer）。

## 檔案

- Modify: lib/features/live/presentation/widgets/timeshift_control_bar.dart
- Test: test/features/live/presentation/widgets/timeshift_control_bar_test.dart

## 新增枚舉

enum TimeshiftMode {
  live,     // 直播模式
  service,  // 服務端時移模式
  buffer,   // 用戶端緩存模式
}

## UI 變更

1. mode 參數改為 TimeshiftMode 枚舉
2. 狀態顯示：
   - live: 紅色「直播中」標籤
   - service: 藍色「時移 XX:XX」標籤
   - buffer: 橙色「緩存中」標籤 + cloud_download 圖示

## 提交訊息

feat(live): enhance TimeshiftControlBar with TimeshiftMode enum
