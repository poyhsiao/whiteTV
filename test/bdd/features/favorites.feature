Feature: 我的收藏功能

  Scenario: 收藏電影
    Given 使用者在電影詳情頁
    When 點擊 "收藏" 按鈕
    Then 收藏按鈕應該變為 "已收藏" 狀態
    And 應該顯示 "已加入我的收藏" toast

  Scenario: 取消收藏
    Given 電影已收藏
    When 使用者點擊 "已收藏" 按鈕
    Then 收藏按鈕應該變為 "收藏" 狀態
    And 應該顯示 "已移除收藏" toast

  Scenario: 收藏頁顯示收藏列表
    Given 用戶有收藏內容
    When 打開 "我的收藏" 頁
    Then 應該顯示收藏列表
    And 應該顯示收藏總數

  Scenario: 空收藏頁顯示引導
    Given 用戶沒有收藏
    When 打開 "我的收藏" 頁
    Then 應該顯示 "還沒有收藏內容"
    And 應該顯示 "去首頁看看" 按鈕

  Scenario: 從收藏進入詳情頁
    Given 收藏頁顯示電影海報
    When 點擊某個收藏
    Then 應該跳轉到該電影詳情頁
