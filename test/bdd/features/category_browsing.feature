Feature: 分類內容瀏覽

  Scenario: TV 模式瀏覽分類內容
    Given 使用者打開 "電影" 分類
    Then 應該顯示 "電影" 標題
    And 應該顯示二級分類 chips
    And 應該顯示影片列表

  Scenario: TV 模式切換二級分類
    Given 使用者打開 "電影" 分類
    When 點擊 "動作" 二級分類
    Then 二級分類狀態應該更新為 "動作"

  Scenario: Mobile 模式瀏覽分類內容
    Given 使用手機開啟 "電視劇" 分類
    Then 應該顯示折疊式篩選區
    And 應該顯示影片列表

  Scenario: 切換排序方式
    Given 使用者打開 "電影" 分類
    When 切換排序為 "評分"
    Then 排序狀態應該更新為 "評分"

  Scenario: 載入失敗顯示錯誤
    Given API 回傳錯誤
    When 使用者打開 "電影" 分類
    Then 應該顯示錯誤訊息
    And 應該顯示 "重新整理" 按鈕
  Scenario: TV 模式切換地區篩選
    Given 使用者打開 "電影" 分類
    When 點擊 "日本" 地區篩選
    Then 地區狀態應該更新為 "jp"
  Scenario: TV 模式切換年份篩選
    Given 使用者打開 "電影" 分類
    When 點擊 "2024" 年份篩選
    Then 年份狀態應該更新為 "2024"
