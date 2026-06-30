Feature: 家長鎖功能

  Scenario: 首次設定家長鎖 PIN
    Given 用戶在設定頁
    And 家長鎖為關閉狀態
    When 用戶點擊 "家長鎖"
    Then 彈出 PIN 設定對話框
    When 用戶輸入 "1234"
    And 再次確認 "1234"
    Then 家長鎖已啟用
    And 顯示 "家長鎖已開啟" 提示

  Scenario: 輸入正確 PIN 觀看限制內容
    Given 家長鎖已啟用
    And 設定的 PIN 是 "1234"
    When 用戶嘗試觀看限制級內容
    Then 彈出 PIN 輸入對話框
    When 用戶輸入正確 PIN "1234"
    Then 內容正常播放

  Scenario: 輸入錯誤 PIN 被阻擋
    Given 家長鎖已啟用
    And 設定的 PIN 是 "1234"
    When 用戶輸入錯誤 PIN "9999"
    Then 顯示 "PIN 錯誤"
    And 失敗次數 +1
    And 內容被阻擋

  Scenario: 連續輸入錯誤 5 次鎖定
    Given 家長鎖已啟用
    And 設定的 PIN 是 "1234"
    When 用戶連續輸入錯誤 PIN 5 次
    Then 顯示 "已鎖定，請 30 分鐘後再試"
    And 家長鎖暫時鎖定

  Scenario: 關閉家長鎖需要驗證 PIN
    Given 家長鎖已啟用
    And 設定的 PIN 是 "1234"
    When 用戶嘗試關閉家長鎖
    Then 彈出 PIN 輸入對話框
    When 用戶輸入正確 PIN "1234"
    Then 家長鎖已關閉

  Scenario: 未設定家長鎖時可直接觀看
    Given 家長鎖為關閉狀態
    When 用戶觀看任何內容
    Then 內容正常播放
    And 不彈出 PIN 對話框
