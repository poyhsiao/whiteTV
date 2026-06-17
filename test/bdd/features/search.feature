Feature: 搜尋功能

  Scenario: 使用遙控器輸入搜尋關鍵字
    Given 使用者在搜尋頁
    When 按下遙控器數字鍵 "movie"
    Then 搜尋框應該顯示 "movie"
    And 應該顯示搜尋建議

  Scenario: 搜尋結果顯示列表
    Given 用戶輸入 "Spider"
    When 點擊搜尋按鈕
    Then 應該顯示搜尋結果列表
    And 結果數量應該大於 0

  Scenario: 空搜尋結果顯示提示
    Given 用戶輸入不存在的關鍵字
    When 點擊搜尋按鈕
    Then 應該顯示 "找不到相關內容"
    And 應該顯示 "試試其他關鍵字" 提示

  Scenario: 搜尋歷史記錄
    Given 用戶已完成多次搜尋
    When 使用者打開搜尋頁
    Then 應該顯示搜尋歷史
    And 歷史記錄應該按時間排序

  Scenario: 清除搜尋歷史
    Given 搜尋歷史顯示中
    When 使用者點擊 "清除"
    Then 搜尋歷史應該被刪除

  Scenario: QR Code 輸入搜尋關鍵字
    Given 使用者在 TV 搜尋頁
    When 使用者掃描 QR Code
    And 手機輸入 "test search"
    Then 搜尋框應該顯示 "test search"
    And 應該自動觸發搜尋
