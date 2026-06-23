Feature: 直播時移功能

  Scenario: 用戶觀看直播並回看過去內容
    Given 用戶正在觀看直播頻道
    When 用戶拖曳時間軸到 10 分鐘前
    Then 播放器從緩衝播放過去的內容
    And 畫面顯示「回看中」

  Scenario: 緩衝已滿，舊內容被淘汰
    Given 緩衝已達到設定的上限
    When 用戶嘗試拖曳到更早的時間
    Then 時間軸停在最舊的可用片段

  Scenario: 用戶回到直播
    Given 用戶正在觀看回看內容
    When 用戶點擊「直播中」按鈕
    Then 播放器回到即時直播
