import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';

class FavoritesStore extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  FavoritesRemoteService? get _remoteService {
    try {
      return ref.read(favoritesRemoteServiceProvider);
    } catch (_) {
      return null;
    }
  }

  void toggleView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final remoteService = _remoteService;
    if (remoteService == null) {
      state = state.copyWith(isLoading: false, error: 'Remote service not configured');
      return;
    }

    try {
      final items = await remoteService.fetchFavorites();
      state = state.copyWith(items: items, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

  Future<void> syncToServer() async {
    final remoteService = _remoteService;
    if (remoteService == null) return;
    state = state.copyWith(isSyncing: true);
    try {
      await remoteService.syncToServer(state.items);
      state = state.copyWith(isSyncing: false);
    } on Exception catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }
}

final favoritesStoreProvider = NotifierProvider<FavoritesStore, FavoritesState>(
  FavoritesStore.new,
);
