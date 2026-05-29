import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoritesStore extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  void toggleView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  void loadFavorites() {
    // Placeholder - will be implemented with actual data loading
    state = state.copyWith(isLoading: false, error: null);
  }

  void removeFavorite(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  void addFavorite(FavoriteItem item) {
    if (state.items.any((i) => i.id == item.id)) return;
    state = state.copyWith(
      items: [...state.items, item],
    );
  }

  void setItems(List<FavoriteItem> items) {
    state = state.copyWith(items: items, isLoading: false, clearError: true);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void setSyncing(bool isSyncing) {
    state = state.copyWith(isSyncing: isSyncing);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final favoritesStoreProvider = NotifierProvider<FavoritesStore, FavoritesState>(
  FavoritesStore.new,
);