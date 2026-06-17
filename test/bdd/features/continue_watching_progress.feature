Feature: 續播進度顯示

  Scenario: 首頁顯示最近觀看的播放進度
    Given 使用者在首頁
    And 最近觀看列表有項目
    Then 應該顯示播放進度條
    And 應該顯示進度百分比

  Scenario: 進度條顯示正確的百分比
    Given 最近觀看項目進度為 50%
    When 渲染海報卡片
    Then 應該顯示 "50%" 文字
    And 進度條應該填充 50%

  Scenario: 零進度不顯示進度條
    Given 最近觀看項目進度為 0%
    When 渲染海報卡片 with showProgress=true
    Then 應該顯示 "0%" 文字
    And 進度條應該為空

  Scenario: 關閉進度顯示時不渲染進度條
    Given 最近觀看項目進度為 50%
    When 渲染海報卡片 with showProgress=false
    Then 不應該顯示進度條
    And 不應該顯示百分比文字

  Scenario: HistoryTile 顯示與海報卡片相同的進度
    Given 歷史記錄項目進度為 85%
    When 渲染 HistoryTile
    Then 應該顯示 "[85%] ████████░" 格式
    And 應該顯示 LinearProgressIndicator
