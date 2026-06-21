// lib/core/ios/ios_platform_channel.dart
import 'package:flutter/services.dart';

/// iOS Platform Channel 介面 - 用於測試注入
abstract interface class IosPlatformChannelInterface {
  Future<bool> startHandoff(String activityType, Map<String, dynamic> userInfo);
  Future<void> updateHandoff(Map<String, dynamic> userInfo);
  Future<void> endHandoff();
  Future<Map<String, dynamic>?> receiveHandoff();
  Future<bool> startPiP(String route);
  Future<void> stopPiP();
  Future<bool> isPiPSupported();
}

/// iOS Platform Channel 封裝
/// 處理 Flutter 與 iOS 原生層的溝通
class IosPlatformChannel implements IosPlatformChannelInterface {
  const IosPlatformChannel._internal();

  static const _channel = MethodChannel('com.white_tv/ios');

  static IosPlatformChannelInterface get instance => _instance;
  static final IosPlatformChannel _instance = const IosPlatformChannel._internal();

  // ignore: unused_element
  factory IosPlatformChannel() => _instance;

  @override
  Future<bool> startHandoff(
    String activityType,
    Map<String, dynamic> userInfo,
  ) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'handoff.startActivity',
        {
          'type': activityType,
          'userInfo': userInfo,
        },
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> updateHandoff(Map<String, dynamic> userInfo) async {
    try {
      await _channel.invokeMethod<void>(
        'handoff.updateActivity',
        {'userInfo': userInfo},
      );
    } on PlatformException {
      // ignore: 降級處理
    }
  }

  @override
  Future<void> endHandoff() async {
    try {
      await _channel.invokeMethod<void>('handoff.endActivity');
    } on PlatformException {
      // ignore: 降級處理
    }
  }

  @override
  Future<Map<String, dynamic>?> receiveHandoff() async {
    try {
      final result = await _channel.invokeMethod<Map>('handoff.receiveActivity');
      return result?.cast<String, dynamic>();
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> startPiP(String route) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'pip.start',
        {'route': route},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> stopPiP() async {
    try {
      await _channel.invokeMethod<void>('pip.stop');
    } on PlatformException {
      // ignore: 降級處理
    }
  }

  @override
  Future<bool> isPiPSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('pip.isSupported');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
