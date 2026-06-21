# Task 5 Brief: 時移播放 BDD 測試

## 任務描述

撰寫時移播放功能的 BDD 驗收測試。

## 檔案

Create: `test/features/live/live_timeshift_bdd_test.dart`

## BDD 測試情境

1. 用戶觀看直播時想回看之前的內容
   - GIVEN 用戶正在觀看直播
   - WHEN 用戶拖曳時間軸
   - THEN 播放器開始播放時移內容

2. 服務端不支援時使用本地緩存
   - GIVEN 服務端時移 API 回應 404
   - WHEN 用戶嘗試時移
   - THEN 系統使用本地緩存播放

3. 用戶想回到直播
   - GIVEN 用戶正在觀看時移內容
   - WHEN 用戶點擊 [直播中] 按鈕
   - THEN 播放器回到直播串流

## 提交訊息

feat(live): add BDD tests for timeshift playback
