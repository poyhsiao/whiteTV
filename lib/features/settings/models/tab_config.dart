/// Configuration for a navigation tab in the bottom/side navigation bar.
///
/// Each tab has an identifier, display label, visibility flag, and ordering index.
/// The [defaultTabs] constant provides the standard six tabs in their default order.
class TabConfig {
  /// Unique identifier for this tab (e.g. 'home', 'categories').
  final String id;

  /// Display label shown in the navigation UI.
  final String label;

  /// Whether this tab is currently visible in the navigation.
  final bool isVisible;

  /// Ordering index; lower values appear first.
  final int order;

  const TabConfig({
    required this.id,
    required this.label,
    this.isVisible = true,
    this.order = 0,
  });

  TabConfig copyWith({
    String? id,
    String? label,
    bool? isVisible,
    int? order,
  }) {
    return TabConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          isVisible == other.isVisible &&
          order == other.order;

  @override
  int get hashCode => Object.hash(id, label, isVisible, order);

  @override
  String toString() =>
      'TabConfig(id: $id, label: $label, isVisible: $isVisible, order: $order)';
}

/// The standard six navigation tabs in their default order.
const List<TabConfig> defaultTabs = [
  TabConfig(id: 'home', label: '首頁', order: 0),
  TabConfig(id: 'categories', label: '分類', order: 1),
  TabConfig(id: 'live', label: '直播', order: 2),
  TabConfig(id: 'search', label: '搜尋', order: 3),
  TabConfig(id: 'favorites', label: '收藏', order: 4),
  TabConfig(id: 'settings', label: '設定', order: 5),
];
