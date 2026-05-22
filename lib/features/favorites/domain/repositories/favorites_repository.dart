import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

abstract interface class FavoritesRepository {
  Future<List<FavoriteItem>> getAll();
  Future<void> add(FavoriteItem item);
  Future<void> remove(String id);
  Future<bool> isFavorite(String id);
  Future<void> sync();
}