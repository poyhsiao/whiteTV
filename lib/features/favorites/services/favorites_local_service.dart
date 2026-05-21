import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesLocalService implements FavoritesRepository {
  static const _key = 'favorites_items';
  final SharedPreferences _prefs;

  FavoritesLocalService(this._prefs);

  @override
  Future<List<FavoriteItem>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => FavoriteItem(
      id: e['id'],
      title: e['title'],
      posterUrl: e['posterUrl'],
      type: e['type'],
      isAvailable: e['isAvailable'] ?? true,
      addedAt: DateTime.parse(e['addedAt']),
    )).toList();
  }

  @override
  Future<void> add(FavoriteItem item) async {
    final items = await getAll();
    items.add(item);
    await _saveAll(items);
  }

  @override
  Future<void> remove(String id) async {
    final items = await getAll();
    items.removeWhere((item) => item.id == id);
    await _saveAll(items);
  }

  @override
  Future<bool> isFavorite(String id) async {
    final items = await getAll();
    return items.any((item) => item.id == id);
  }

  @override
  Future<void> sync() async {
    // Local service doesn't sync - that's the remote service's job
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  Future<void> _saveAll(List<FavoriteItem> items) async {
    final json = jsonEncode(items.map((e) => {
      'id': e.id,
      'title': e.title,
      'posterUrl': e.posterUrl,
      'type': e.type,
      'isAvailable': e.isAvailable,
      'addedAt': e.addedAt.toIso8601String(),
    }).toList());
    await _prefs.setString(_key, json);
  }
}