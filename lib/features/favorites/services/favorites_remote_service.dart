import 'package:dio/dio.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoritesRemoteService {
  final Dio _dio;

  FavoritesRemoteService(String baseUrl) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<FavoriteItem>> fetchFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => FavoriteItem(
          id: e['id']?.toString() ?? '',
          title: e['title'] ?? '',
          posterUrl: e['posterUrl'] ?? e['cover'] ?? '',
          type: e['type'] ?? 'movie',
          isAvailable: e['isAvailable'] ?? true,
          addedAt: e['addedAt'] != null
              ? DateTime.parse(e['addedAt'])
              : DateTime.now(),
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> syncToServer(List<FavoriteItem> items) async {
    try {
      final data = items.map((e) => {
        'id': e.id,
        'title': e.title,
        'posterUrl': e.posterUrl,
        'type': e.type,
      }).toList();
      await _dio.post('/favorites/sync', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addFavorite(FavoriteItem item) async {
    try {
      await _dio.post('/favorites', data: {
        'id': item.id,
        'title': item.title,
        'posterUrl': item.posterUrl,
        'type': item.type,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String id) async {
    try {
      await _dio.delete('/favorites/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}