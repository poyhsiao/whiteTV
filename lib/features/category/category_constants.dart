/// 分類瀏覽 - 排序選項
enum SortOption {
  recentUpdate,
  rating,
  popularity,
  recentAdded,
  alphabetical;

  String get label {
    return switch (this) {
      SortOption.recentUpdate => '最近更新',
      SortOption.rating => '評分',
      SortOption.popularity => '播放量',
      SortOption.recentAdded => '最近添加',
      SortOption.alphabetical => '字母',
    };
  }
}

/// 分類瀏覽 - 常數與標籤映射
abstract final class CategoryConstants {
  CategoryConstants._();

  static const subCategories = [
    'all', 'action', 'comedy', 'sci_fi', 'romance',
    'thriller', 'war', 'horror', 'animation', 'drama', 'documentary',
  ];

  static const regions = [
    'all', 'cn', 'hk', 'tw', 'jp', 'kr', 'us', 'eu',
  ];

  static const years = [
    'all', '2024', '2023', '2022', '2021', '2020', 'earlier',
  ];

  static const sortOptions = SortOption.values;

  static String subCategoryLabel(String key) {
    return switch (key) {
      'all' => '全部',
      'action' => '動作',
      'comedy' => '喜劇',
      'sci_fi' => '科幻',
      'romance' => '愛情',
      'thriller' => '懸疑',
      'war' => '戰爭',
      'horror' => '恐怖',
      'animation' => '動畫',
      'drama' => '劇情',
      'documentary' => '紀錄片',
      _ => key,
    };
  }

  static String regionLabel(String key) {
    return switch (key) {
      'all' => '全部',
      'cn' => '大陸',
      'hk' => '香港',
      'tw' => '台灣',
      'jp' => '日本',
      'kr' => '韓國',
      'us' => '美國',
      'eu' => '歐洲',
      _ => key,
    };
  }

  static String yearLabel(String key) {
    return switch (key) {
      'all' => '全部',
      'earlier' => '更早期',
      _ => key,
    };
  }
}
