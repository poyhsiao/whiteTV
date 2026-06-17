Feature: 登入驗證功能

  Scenario: QR Code 登入成功
    Given TV 顯示登入 QR Code
    When 手機掃描 QR
    And 手機輸入帳號密碼
    And 手機點擊登入
    Then TV 應該顯示登入成功
    And 應該跳轉到首頁

  Scenario: QR Code 過期刷新
    Given QR Code 顯示超過 5 分鐘
    When TV 顯示 QR
    Then 應該顯示 "QR 已過期"
    And 應該自動刷新 QR Code

  Scenario: 登入失敗顯示錯誤
    Given 手機掃描 QR Code
    When 手機輸入錯誤密碼
    Then TV 應該顯示 "登入失敗"
    And 應該顯示 "請重試" 提示

  Scenario: 登出功能
    Given 用戶已登入
    When 點擊 "登出"
    Then 應該顯示確認對話框
    When 確認登出
    Then 應該清除登入狀態
    And 應該返回首頁

  Scenario: 登入狀態保持
    Given 用戶已登入
    When 關閉並重新打開 App
    Then 應該保持登入狀態
