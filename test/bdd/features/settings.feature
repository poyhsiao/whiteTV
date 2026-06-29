Feature: 設定頁功能

  Scenario: 設定頁正確顯示所有分類
    Given 使用者打開設定頁
    Then 應該顯示 "播放設定"
    And 應該顯示 "顯示設定"
    And 應該顯示 "家長控制"
    And 應該顯示 "關於"

  Scenario: 播放來源屏蔽
    Given 使用者在播放設定
    When 查看可用來源列表
    Then 應該顯示所有來源
    And 應該標記已屏蔽的來源
    When 切換來源屏蔽狀態
    Then 應該更新屏蔽列表

  Scenario: 畫質偏好設定
    Given 使用者在播放設定
    When 點擊畫質設定
    Then 應該顯示畫質選項
    When 選擇 "流暢優先"
    Then 應該儲存設定

  Scenario: 子女模式開關
    Given 使用者在家長控制
    When 點擊 "子女模式" 開關
    Then 子女模式應該開啟/關閉
    And 應該要求輸入 PIN 確認

  Scenario: 家長 PIN 碼設定
    Given 使用者首次設定 PIN
    When 輸入新 PIN 碼
    And 再次輸入確認
    Then PIN 應該設定成功
    And 應該顯示 "設定成功"

  Scenario: 版本資訊顯示
    Given 使用者在關於頁
    Then 應該顯示 App 版本號
    And 應該顯示構建號

  Scenario: 清除快取
    Given 使用者想釋放空間
    When 點擊 "清除快取"
    Then 應該顯示快取大小
    When 確認清除
    Then 快取應該被清除
    And 應該顯示 "清除成功"

  Scenario: 家長鎖啟用後以正確 PIN 通過驗證
    Given 使用者已啟用家長鎖並設定 PIN 為 "1234"
    When 輸入 PIN "1234" 嘗試播放限制級內容
    Then 應該驗證成功並允許繼續

  Scenario: 家長鎖啟用後以錯誤 PIN 被阻擋
    Given 使用者已啟用家長鎖並設定 PIN 為 "1234"
    When 輸入 PIN "9999" 嘗試播放限制級內容
    Then 應該驗證失敗並要求重新輸入
    And 失敗次數應該記錄為 1

  Scenario: 家長鎖未啟用時不應阻擋
    Given 使用者未啟用家長鎖
    When 嘗試播放限制級內容
    Then 不應該要求輸入 PIN
