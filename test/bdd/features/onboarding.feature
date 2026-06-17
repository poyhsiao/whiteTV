Feature: 新用戶引導功能

  Scenario: 首次啟動顯示歡迎頁
    Given 用戶首次啟動 App
    Then 應該顯示歡迎頁
    And 應該顯示 "歡迎使用 whiteTV"

  Scenario: 引導頁滑動切換
    Given 歡迎頁顯示中
    When 滑動到下一頁
    Then 應該切換到下一個引導內容
    And 指示器應該更新

  Scenario: 引導內容完整展示
    Given 引導頁滑動到最後一頁
    Then 應該展示主要功能介紹
    And 應該顯示 "立即開始" 按鈕

  Scenario: 點擊立即開始進入首頁
    Given 引導頁在最後一頁
    When 點擊 "立即開始"
    Then 應該關閉引導
    And 應該進入首頁

  Scenario: 跳過引導
    Given 引導頁顯示中
    When 點擊 "跳過"
    Then 應該直接進入首頁
    And 不應該再顯示引導

  Scenario: 遙控器操作引導
    Given 引導頁顯示中
    When 按下遙控器 OK 鍵
    Then 應該切換到下一頁
