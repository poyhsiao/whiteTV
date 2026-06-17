Feature: 播放器控制功能

  Scenario: 播放控制欄顯示/隱藏
    Given 視頻正在播放
    When 點擊螢幕任意位置
    Then 播放控制欄應該顯示
    When 5 秒後無操作
    Then 播放控制欄應該自動隱藏

  Scenario: 播放/暫停切換
    Given 視頻正在播放
    When 點擊播放按鈕
    Then 視頻應該暫停
    And 按鈕應該變為播放圖示

  Scenario: 進度條拖動
    Given 播放控制欄顯示
    When 拖動進度條到 50%
    Then 視頻應該跳轉到 50% 處

  Scenario: 快進/快退
    Given 視頻正在播放
    When 按下遙控器右鍵
    Then 視頻應該快進 10 秒

  Scenario: 上一集/下一集
    Given 播放多集內容
    When 點擊 "下一集"
    Then 應該切換到下一集
    And 應該從頭開始播放

  Scenario: 畫質選擇
    Given 視頻有多種畫質可選
    When 點擊畫質按鈕
    Then 應該顯示畫質選項
    And 當前畫質應該標記

  Scenario: 來源選擇
    Given 視頻有多個播放來源
    When 點擊來源按鈕
    Then 應該顯示來源列表
    And 應該標記當前來源

  Scenario: 播放失敗顯示錯誤
    Given 所有來源都無法播放
    When 嘗試播放
    Then 應該顯示 "播放失敗" 提示
    And 應該顯示 "切換來源" 按鈕

  Scenario: 來源自動切換
    Given 當前來源播放失敗
    When 點擊 "自動切換"
    Then 應該嘗試下一個來源
    And 應該顯示 "正在切換來源..."
