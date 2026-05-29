import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoritesLocalService {
  static const _key = 'favorites_items';

  FavoritesLocalService();

  Future<List<FavoriteItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((json) => _fromJson(jsonDecode(json))).toList();
  }

  Future<void> save(FavoriteItem item) async {
    final items = await getAll();
    items.removeWhere((i) => i.id == item.id);
    items.add(item);
    await _saveAll(items);
  }

  Future<void> remove(String id) async {
    final items = await getAll();
    items.removeWhere((i) => i.id == id);
    await _saveAll(items);
  }

  Future<void> _saveAll(List<FavoriteItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((i) => jsonEncode(_toJson(i))).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Map<String, dynamic> _toJson(FavoriteItem item) => {
    'id': item.id,
    'title': item.title,
    'posterUrl': item.posterUrl,
    'type': item.type,
    'isAvailable': item.isAvailable,
    'addedAt': item.addedAt.toIso8601String(),
  };

  FavoriteItem _fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'] as String,
    title: json['title'] as String,
    posterUrl: json['posterUrl'] as String,
    type: json['type'] as String,
    isAvailable: json['isAvailable'] as bool? ?? true,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );
}
