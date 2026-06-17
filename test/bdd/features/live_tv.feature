Feature: 直播電視功能

  Scenario: 直播頻道列表正確顯示
    Given 使用者打開直播頁
    Then 應該顯示頻道分類（新聞/體育/綜藝等）
    And 應該顯示頻道 Logo
    And 應該顯示當前節目名稱

  Scenario: 直播頻道播放
    Given 直播頁顯示頻道列表
    When 點擊某個頻道
    Then 應該開始播放直播
    And 應該顯示 "直播中" 標識

  Scenario: 直播節目表顯示
    Given 正在觀看某個頻道
    When 打開節目表
    Then 應該顯示當前節目
    And 應該顯示接下來的節目
    And 應該標記當前播放時間點

  Scenario: 頻道切換
    Given 正在播放直播
    When 按下遙控器上一頁/下一頁
    Then 應該切換到相鄰頻道

  Scenario: 直播畫質調整
    Given 直播播放中
    When 點擊畫質按鈕
    Then 應該顯示畫質選項
    And 選擇後應該切換畫質

  Scenario: EPG 節目表瀏覽
    Given 使用者打開 EPG
    Then 應該顯示時間軸
    And 應該顯示頻道列表
    And 應該顯示節目時段
    When 點擊某個節目
    Then 應該顯示節目詳情
