// Default fallback implementations for new ApiClient methods.
// Tests that don't care about hot movies / related videos can mix this in
// instead of implementing those methods explicitly.
import 'models.dart';

/// 提供新方法的 default 實作，測試 mock 可 mix 進來避免破壞性變更
mixin ApiClientFallbacks on Object {
  Future<List<Video>> getHotMovies({int limit = 20}) async => const <Video>[];

  Future<List<Video>> getRelatedVideos(String videoId, {int limit = 12}) async => const <Video>[];

  Future<List<YoutubeVideo>> getYoutubeRecommend() async => const <YoutubeVideo>[];

  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async => const <YoutubeVideo>[];

  Future<List<YoutubeCategory>> getYoutubeCategories() async => const <YoutubeCategory>[];
}