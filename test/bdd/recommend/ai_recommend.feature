Feature: AI 推薦功能

  Scenario: AI 推薦成功獲取內容
    Given 用戶已登入
    And AI API 回傳有效推薦
    When 用戶打開首頁
    Then 看到「為你推薦」區塊顯示 AI 推薦內容
    And 卡片顯示「🤖 AI」標籤

  Scenario: AI API 回傳空值，使用 Fallback
    Given 用戶已登入
    And AI API 回傳空值
    When 用戶打開首頁
    Then 看到「為你推薦」區塊顯示本地推薦
    And 卡片顯示「📺 偏好」標籤

  Scenario: 用戶點擊推薦理由按鈕
    Given 推薦卡片顯示中
    When 用戶點擊「為何推薦？」
    Then 底部弹窗顯示推薦理由

  Scenario: 用戶在獨立頁面查看推薦
    Given 用戶在首頁
    When 用戶點擊「AI 推薦」入口
    Then 跳轉到 AI 推薦頁面
    And 顯示所有推薦分類

  Scenario: 用戶下拉刷新推薦
    Given 用戶在 AI 推薦頁面
    When 用戶下拉刷新
    Then 推薦內容重新載入
    And 顯示新的推薦結果