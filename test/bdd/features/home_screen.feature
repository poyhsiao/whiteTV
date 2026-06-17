Feature: 首頁功能

  Scenario: 首頁正確載入分類內容
    Given 使用者打開 App
    When 首頁載入完成
    Then 應該顯示 "電影" 分類
    And 應該顯示 "電視劇" 分類
    And 應該顯示海報卡片

  Scenario: 首頁顯示 AI 推薦區塊
    Given 用戶已登入
    When 首頁載入完成
    Then 應該顯示 "為你推薦" 區塊
    And AI 推薦卡片顯示 "🤖 AI" 標籤

  Scenario: 首頁顯示最近觀看
    Given 用戶有觀看記錄
    When 首頁載入完成
    Then 應該顯示 "最近觀看" 區塊
    And 應該顯示觀看進度條

  Scenario: 點擊海報卡進入詳情頁
    Given 首頁顯示電影海報
    When 使用者點擊海報
    Then 應該跳轉到電影詳情頁

  Scenario: 網路錯誤時顯示重試
    Given 網路連線中斷
    When 使用者打開首頁
    Then 應該顯示 "網路錯誤" 提示
    And 應該顯示 "重新整理" 按鈕

  Scenario: 首頁 Loading 骨架屏
    Given 首頁載入中
    Then 應該顯示骨架屏動畫
    And 不應該顯示實際內容
