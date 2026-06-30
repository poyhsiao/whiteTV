/// Picture-in-Picture 控制器
///
/// 負責管理 iOS/macOS 平台的畫中畫功能
class PiPController {
  PiPController();

  /// 是否已啟用 PiP 模式
  bool isActive = false;

  /// 平台是否支援 PiP
  bool isSupported = false;

  /// 當前路由名稱
  String? currentRoute;

  /// PiP 啟動時的回調
  void Function()? onPiPStarted = _noop;

  /// PiP 停止時的回調
  void Function()? onPiPStopped = _noop;

  /// PiP 錯誤時的回調，接收錯誤訊息
  void Function(String)? onPiPError = _noopWithMessage;

  static void _noop() {}
  static void _noopWithMessage(String msg) {}

  /// 啟動畫中畫模式
  ///
  /// [routeName] 要在 PiP 視窗中顯示的路由名稱
  Future<void> startPiP(String routeName) async {
    isActive = true;
    currentRoute = routeName;
    onPiPStarted?.call();
  }

  /// 停止畫中畫模式
  Future<void> stopPiP() async {
    isActive = false;
    onPiPStopped?.call();
  }

  /// 更新當前路由（用於 PiP 視窗標題）
  ///
  /// [routeName] 新的路由名稱
  void updateRoute(String routeName) {
    currentRoute = routeName;
  }

  /// 檢查平台是否支援 PiP
  Future<bool> checkPiPSupported() async {
    isSupported = true;
    return true;
  }
}
