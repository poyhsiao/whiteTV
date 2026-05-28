import 'models.dart';
import '../../features/search/search_state.dart';
import '../../features/history/models/play_history.dart';

/// API Client 抽象介面
/// 實現: LunaClient (真實) / MockClient (Mock)

abstract class ApiClient {
  /// 登入
  Future<Map<String, String>?> login(String username, String password);

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

  /// 搜尋影片
  Future<List<int>> search(String query, {SearchCategory? category});

  /// 取得使用者統計資料（包含播放歷史）
  Future<Map<String, dynamic>> getUserStats();

  /// 同步搜尋歷史到雲端
  Future<void> syncSearchHistory(List<String> history);

  /// 從雲端取得搜尋歷史
  Future<List<String>> getSearchHistory();

  /// 保存播放歷史記錄到雲端
  Future<bool> savePlayHistory(PlayHistory record);

  /// 取得 IPTV 頻道列表 (JSON 格式)
  Future<List<dynamic>> getIptvChannels();

  /// 取得 IPTV M3U playlist
  Future<String?> getIptvM3U();

  /// 取得 EPG 節目表
  Future<Map<String, dynamic>> getIptvEpg();
}
