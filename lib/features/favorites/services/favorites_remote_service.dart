import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/dio_provider.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

final favoritesRemoteServiceProvider = Provider<FavoritesRemoteService>((ref) {
  // Sprint 7.1 — pull shared Dio instead of constructing one here.
  // baseUrl lives on the overridden Dio (see lib/main.dart ProviderScope).
  return FavoritesRemoteService.withDio(ref.watch(dioProvider));
});

class FavoritesRemoteService {
  FavoritesRemoteService({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
        ),
      );

  /// 注入既有 Dio 實例 (用於測試或自訂 httpClientAdapter)。
  FavoritesRemoteService.fromDio(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<List<FavoriteItem>> fetchFavorites() async {
    final response = await _dio.get('/favorites');
    final List<dynamic> data = response.data['list'] ?? [];
    return data.map((json) => _fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<bool> addFavorite(FavoriteItem item) async {
    await _dio.post(
      '/favorites',
      data: {
        'id': item.id,
        'title': item.title,
        'type': item.type,
        'poster': item.posterUrl,
      },
    );
    return true;
  }

  Future<bool> removeFavorite(String id) async {
    await _dio.delete('/favorites/$id');
    return true;
  }

  Future<bool> syncToServer(List<FavoriteItem> items) async {
    await _dio.post(
      '/favorites/sync',
      data: {
        'items': items
            .map(
              (i) => {
                'id': i.id,
                'type': i.type,
                'addedAt': i.addedAt.toIso8601String(),
              },
            )
            .toList(),
      },
    );
    return true;
  }

  FavoriteItem _fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'] as String,
    title: json['title'] as String,
    posterUrl: json['poster'] as String? ?? '',
    type: json['type'] as String? ?? 'movie',
    isAvailable: json['available'] as bool? ?? true,
    addedAt: json['addedAt'] != null
        ? DateTime.parse(json['addedAt'] as String)
        : DateTime.now(),
  );
}
