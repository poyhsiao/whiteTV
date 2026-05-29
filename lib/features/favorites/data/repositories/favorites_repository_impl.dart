import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._remote, this._local);

  final FavoritesRemoteService _remote;
  final FavoritesLocalService _local;

  @override
  Future<List<FavoriteItem>> getAll() async {
    try {
      // Remote-first: fetch from LunaTV
      final remoteItems = await _remote.fetchFavorites();
      // Merge with local
      final localItems = await _local.getAll();
      final merged = _mergeItems(remoteItems, localItems);
      // Save merged to local
      await _local.saveAll(merged);
      return merged;
    } catch (e) {
      // Fallback to local if remote fails
      return _local.getAll();
    }
  }

  @override
  Future<void> add(FavoriteItem item) async {
    await _local.save(item);
    try {
      await _remote.addFavorite(item);
    } catch (_) {
      // Will sync later
    }
  }

  @override
  Future<void> remove(String id) async {
    await _local.remove(id);
    try {
      await _remote.removeFavorite(id);
    } catch (_) {
      // Will sync later
    }
  }

  @override
  Future<bool> isFavorite(String id) async {
    final items = await _local.getAll();
    return items.any((item) => item.id == id);
  }

  @override
  Future<void> sync() async {
    final localItems = await _local.getAll();
    await _remote.syncToServer(localItems);
  }

  List<FavoriteItem> _mergeItems(List<FavoriteItem> remote, List<FavoriteItem> local) {
    final Map<String, FavoriteItem> merged = {};
    for (final item in remote) {
      merged[item.id] = item;
    }
    for (final item in local) {
      if (!merged.containsKey(item.id)) {
        merged[item.id] = item;
      }
    }
    return merged.values.toList();
  }
}

extension _FavoritesLocalServiceExtension on FavoritesLocalService {
  Future<void> saveAll(List<FavoriteItem> items) async {
    for (final item in items) {
      await save(item);
    }
  }
}