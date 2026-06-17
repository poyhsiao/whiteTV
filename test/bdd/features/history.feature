Feature: 觀看紀錄功能

  Scenario: 播放後自動新增紀錄
    Given 用戶觀看電影 5 分鐘
    When 退出播放器
    Then 應該在觀看紀錄中看到該電影
    And 進度應該顯示 "5 分鐘"

  Scenario: 觀看進度顯示百分比
    Given 用戶觀看電影進度為 50%
    When 打開觀看紀錄頁
    Then 應該顯示 "50%"
    And 應該顯示進度條

  Scenario: 從紀錄繼續播放
    Given 用戶有觀看進度 30% 的電影
    When 點擊該記錄
    Then 應該從 30% 處開始播放

  Scenario: 刪除單條記錄
    Given 觀看紀錄頁顯示記錄列表
    When 長按某條記錄
    Then 應該顯示刪除選項
    When 點擊刪除
    Then 該記錄應該被移除

  Scenario: 清空所有紀錄
    Given 觀看紀錄頁顯示記錄列表
    When 點擊 "清空"
    Then 應該顯示確認對話框
    When 確認清空
    Then 所有記錄應該被刪除

  Scenario: 空觀看紀錄
    Given 用戶從未觀看任何內容
    When 打開觀看紀錄頁
    Then 應該顯示 "還沒有觀看紀錄"
    And 應該顯示 "去首頁看看" 按鈕
