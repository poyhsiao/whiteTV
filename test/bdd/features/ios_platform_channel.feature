Feature: iOS Platform Channel

  Scenario: Handoff 開始活動
    Given 使用者在 iPhone 播放影片
    And 影片 ID 為 "movie-123"
    When 使用者開啟 Handoff
    Then 平台通道調用 handoff.startActivity
    And 返回成功狀態

  Scenario: Handoff 接收活動
    Given 另一設備發送了 Handoff 活動
    When 應用程式接收活動
    Then 返回包含 contentId 的 userInfo
    And contentId 為 "movie-123"

  Scenario: PiP 模式檢查支援
    Given 使用者正在觀看影片
    When 檢查是否支援子母畫面
    Then 在 iOS 15+ 返回 true
    And 在較舊版本返回 false

  Scenario: 非 iOS 平台降級
    Given 使用者在 Android TV
    When 調用平台通道
    Then 返回 false 或 null
    And 不拋出異常
