import Flutter
import UIKit

/// 統一 iOS Platform Plugin
/// 處理 Flutter 與 iOS 原生層的所有溝通
public class UnifiedIosPlatformPlugin: NSObject, FlutterPlugin {

    // MARK: - Singleton
    public static let shared = UnifiedIosPlatformPlugin()

    // MARK: - Handoff State
    private var currentActivity: NSUserActivity?
    private var userInfoCache: [String: Any] = [:]

    // MARK: - FlutterPlugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.white_tv/ios",
            binaryMessenger: registrar.messenger()
        )
        let instance = UnifiedIosPlatformPlugin.shared
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "handoff.startActivity":
            handleStartActivity(call: call, result: result)
        case "handoff.updateActivity":
            handleUpdateActivity(call: call, result: result)
        case "handoff.endActivity":
            handleEndActivity(result: result)
        case "handoff.receiveActivity":
            handleReceiveActivity(result: result)
        case "pip.start":
            handleStartPiP(call: call, result: result)
        case "pip.stop":
            handleStopPiP(result: result)
        case "pip.isSupported":
            handleIsPiPSupported(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Handoff Handlers

    private func handleStartActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let activityType = args["type"] as? String,
              let userInfo = args["userInfo"] as? [String: Any] else {
            result(false)
            return
        }

        let activity = NSUserActivity(activityType: activityType)
        activity.userInfo = userInfo
        activity.isEligibleForHandoff = true
        activity.becomeCurrent()

        currentActivity = activity
        userInfoCache = userInfo

        result(true)
    }

    private func handleUpdateActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let userInfo = args["userInfo"] as? [String: Any] else {
            result(nil)
            return
        }

        userInfoCache = userInfo
        currentActivity?.userInfo = userInfo
        currentActivity?.needsSave = true

        result(nil)
    }

    private func handleEndActivity(result: @escaping FlutterResult) {
        currentActivity?.invalidate()
        currentActivity = nil
        userInfoCache = [:]
        result(nil)
    }

    private func handleReceiveActivity(result: @escaping FlutterResult) {
        // iOS 會自動通過 App Delegate 接收 Handoff
        // 這裡返回快取的數據
        result(userInfoCache.isEmpty ? nil : userInfoCache)
    }

    // MARK: - PiP Handlers

    private func handleStartPiP(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // PiP 需要 AVPictureInPictureController
        // 完整實作需要整合 media_kit
        // 這裡返回 false 表示尚未支援
        result(false)
    }

    private func handleStopPiP(result: @escaping FlutterResult) {
        result(nil)
    }

    private func handleIsPiPSupported(result: @escaping FlutterResult) {
        // 檢查設備是否支援 PiP
        if #available(iOS 15.0, *) {
            result(true)
        } else {
            result(false)
        }
    }
}