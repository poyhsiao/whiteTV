Feature: 下載功能

  Scenario: 使用者下載影片後出現在下載列表
    Given 用戶在詳情頁
    And 影片 "星際穿越" 有下載按鈕
    When 用戶點擊 "下載"
    Then 下載任務開始
    And 下載完成後出現在 "我的下載"

  Scenario: 下載列表顯示下載進度
    Given 用戶有進行中的下載
    When 用戶進入下載頁面
    Then 顯示下載進度百分比
    And 顯示已下載 / 總大小

  Scenario: 使用者刪除下載
    Given 用戶在下載頁面
    And 下載列表有 "星際穿越"
    When 用戶長按該項目
    Then 顯示刪除選項
    When 用戶確認刪除
    Then 從下載列表移除
    And 刪除本地檔案

  Scenario: 下載失敗時顯示錯誤
    Given 用戶開始下載
    When 網路連線中斷
    Then 顯示 "下載失敗" 提示
    And 顯示 "重試" 按鈕

  Scenario: 離線觀看下載的影片
    Given 用戶已下載 "星際穿越"
    And 網路已斷開
    When 用戶進入下載頁
    And 點擊 "星際穿越"
    Then 可以正常播放

  Scenario: 下載頁空狀態
    Given 用戶從未下載任何影片
    When 用戶進入下載頁
    Then 顯示空狀態插圖
    And 顯示 "開始探索" 按鈕
