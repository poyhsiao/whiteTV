import 'models.dart';

/// API Client 抽象介面
/// 實現: LunaClient (真實) / MockClient (Mock)

abstract class ApiClient {
  /// 取得分類列表
  Future<List<Category>> getCategories();

  /// 依分類取得影片列表
  Future<List<Video>> getVideosByCategory(String categoryId);

  /// 取得影片詳情
  Future<VideoDetail> getVideoDetail(String videoId);

  /// 取得影片來源
  Future<List<VideoSource>> getSources(String videoId);

  /// 測試來源速度
  Future<int> testSourceLatency(String sourceUrl);
}