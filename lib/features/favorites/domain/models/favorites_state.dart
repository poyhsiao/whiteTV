import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoritesState {
  final List<FavoriteItem> items;
  final bool isLoading;
  final String? error;
  final bool isGridView;
  final String filterType;
  final bool isSyncing;

  const FavoritesState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.isGridView = true,
    this.filterType = 'all',
    this.isSyncing = false,
  });

  List<FavoriteItem> get filteredItems {
    if (filterType == 'all') return items;
    return items.where((item) => item.type == filterType).toList();
  }

  List<FavoriteItem> get availableItems {
    return items.where((item) => item.isAvailable).toList();
  }

  List<FavoriteItem> get unavailableItems {
    return items.where((item) => !item.isAvailable).toList();
  }

  FavoritesState copyWith({
    List<FavoriteItem>? items,
    bool? isLoading,
    String? error,
    bool? isGridView,
    String? filterType,
    bool? isSyncing,
    bool clearError = false,
  }) {
    return FavoritesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isGridView: isGridView ?? this.isGridView,
      filterType: filterType ?? this.filterType,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}