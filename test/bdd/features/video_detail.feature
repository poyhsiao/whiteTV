Feature: 影片詳情頁功能

  Scenario: 詳情頁顯示完整資訊
    Given 使用者點擊電影海報
    When 詳情頁載入完成
    Then 應該顯示電影名稱
    And 應該顯示評分
    And 應該顯示年份和時長
    And 應該顯示簡介

  Scenario: 播放按鈕直達播放器
    Given 詳情頁顯示中
    When 點擊 "播放" 按鈕
    Then 應該直接進入播放器
    And 應該從上次進度或從頭開始

  Scenario: 預告片播放
    Given 詳情頁顯示中
    When 點擊 "預告片" 按鈕
    Then 應該開始播放預告片
    And 預告片播放完畢後停留在詳情頁

  Scenario: 收藏/取消收藏
    Given 詳情頁顯示中
    When 點擊收藏按鈕
    Then 應該切換收藏狀態
    And 應該顯示 toast 提示

  Scenario: 選集列表
    Given 內容為多集電視劇
    When 滾動到選集區域
    Then 應該顯示集數列表
    And 應該標記已觀看集數

  Scenario: 相關推薦
    Given 詳情頁顯示中
    When 滾動到頁面底部
    Then 應該顯示 "相關推薦"
    And 應該顯示相關電影海報

  Scenario: 家長控制鎖定內容
    Given 內容被設為家長鎖定
    When 使用者未解鎖
    Then 應該顯示家長鎖提示
    And 應該需要輸入 PIN 碼
