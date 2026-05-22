Feature: 統一輸入系統

  Scenario: 手機成功輸入文字到 TV
    Given TV 顯示 QR Code
    And 手機已連接相同 WiFi
    When 手機掃描 QR Code
    And 手機輸入 "test123"
    And 手機點擊發送
    Then TV 畫面應該顯示 "test123"

  Scenario: TV 正確關閉 Server
    Given 輸入完成
    When 使用者點擊 "完成"
    Then Local HTTP Server 應該關閉

  Scenario: Port 被佔用時自動切換
    Given Port 8080 被佔用
    When 啟動 InputService
    Then Server 應該使用下一個可用 Port

  Scenario: 無 WiFi 時正確降級
    Given TV 無法取得有效 IP
    When 使用者嘗試使用 QR 輸入
    Then 應該顯示 "無法使用手機輸入" 提示
    And 應該提供 "使用遙控器輸入" 選項

  Scenario: 輸入超時自動關閉
    Given 輸入Session 已開始
    When 超過 5 分鐘無活動
    Then Server 應該自動關閉