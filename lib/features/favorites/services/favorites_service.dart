import 'dart:async';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesService {
  const FavoritesService({required this._repository});

  final FavoritesRepository _repository;

  Future<void> addFavorite(FavoriteItem item) async {
    await _repository.add(item);
    _backgroundSync();
  }

  Future<void> removeFavorite(String id) async {
    await _repository.remove(id);
    _backgroundSync();
  }

  Future<List<FavoriteItem>> getFavorites() async {
    return _repository.getAll();
  }

  Future<bool> isFavorite(String id) async {
    return _repository.isFavorite(id);
  }

  Future<void> syncWithServer() async {
    await _repository.sync();
  }

  void _backgroundSync() {
    Future.delayed(const Duration(seconds: 2), () {
      _repository.sync();
    });
  }
}