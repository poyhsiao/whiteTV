Feature: YouTube 專區功能

  Scenario: 用戶瀏覽 YouTube 推薦影片
    Given 用戶在首頁
    When 用戶滾動到 YouTube 專區
    Then 顯示 YouTube 影片列表
    And 顯示影片標題和時長

  Scenario: 用戶點擊 YouTube 影片
    Given 用戶在首頁 YouTube 專區
    When 用戶點擊某個影片
    Then 導航到 YouTube 播放頁面

  Scenario: 用戶瀏覽 YouTube 分類
    Given 用戶進入 YouTube 分類頁面
    When 頁面載入完成
    Then 顯示分類導航列
    And 顯示預設分類的影片網格

  Scenario: 用戶選擇不同分類
    Given 用戶在 YouTube 分類頁面
    And 已選擇第一個分類
    When 用戶點擊第二個分類
    Then 載入第二個分類的影片
    And 更新影片網格顯示

  Scenario: 用戶切換回首頁 YouTube 專區
    Given 用戶在 YouTube 分類頁面
    When 用戶返回首頁
    Then 首頁顯示 YouTube 專區
