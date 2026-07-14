Feature: AI 推薦功能

  Scenario: AI 推薦頁正確顯示
    Given 使用者打開 AI 推薦頁
    Then 應該顯示載入中指示器
    When 載入完成
    Then 應該顯示推薦內容網格
    And 應該顯示 "AI 智能推薦" 標題
    And 應該顯示 "根據您的偏好" 標題
    And 應該顯示 "熱門推薦" 標題

  Scenario: AI 推薦列表正確分類
    Given AI 推薦載入完成
    Then 應該分組顯示 AI 推薦
    And 應該分組顯示基於歷史的推薦
    And 應該分組顯示熱門推薦

  Scenario: 推薦內容顯示正確資訊
    Given AI 推薦載入完成
    Then 每個推薦項目應該顯示標題
    And 每個推薦項目應該顯示海報
    And 每個推薦項目應該顯示推薦原因

  Scenario: 使用者下拉刷新推薦內容
    Given AI 推薦頁顯示推薦內容
    When 使用者下拉刷新
    Then 應該顯示載入中指示器
    And 應該重新載入推薦內容

  Scenario: 無推薦內容顯示空狀態
    Given AI 推薦載入完成
    And 沒有可用推薦
    Then 應該顯示空狀態插圖
    And 應該顯示 "暫無推薦內容" 文字

  Scenario: AI 推薦載入失敗顯示錯誤
    Given AI 推薦頁
    When 網路錯誤發生
    Then 應該顯示錯誤訊息
    And 應該顯示重試按鈕

  Scenario: 使用者點擊推薦項目進入詳情
    Given AI 推薦頁顯示推薦內容
    When 使用者點擊某個推薦項目
    Then 應該導航到該項目詳情頁

  Scenario: 首頁顯示 AI 推薦區塊
    Given 使用者在首頁
    Then 應該顯示 "為你推薦" 區塊
    And 應該橫向滾動顯示推薦內容

  Scenario: AI 推薦區塊點擊查看更多
    Given 首頁顯示 AI 推薦區塊
    When 使用者點擊 "查看更多"
    Then 應該導航到 AI 推薦完整頁
