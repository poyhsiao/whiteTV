import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/feature_flags.dart';
import 'package:white_tv/core/device/pip/pip_controller.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  late PiPController controller;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    controller = PiPController();
  });

  group('PiPController', () {
    group('Feature Flag Gating', () {
      test('PiP 启用时 enablePiP 返回 true', () {
        for (final type in [DeviceType.mobile, DeviceType.tablet, DeviceType.desktop]) {
          expect(FeatureFlags.enablePiP(type), isTrue,
              reason: '$type should support PiP');
        }
      });
      test('TV 平台停用 PiP', () {
        expect(FeatureFlags.enablePiP(DeviceType.tv), isFalse);
      });
    });

    group('Initial State', () {
      test('isActive 初始为 false', () {
        expect(controller.isActive, isFalse);
      });
      test('isSupported 初始为 false', () {
        expect(controller.isSupported, isFalse);
      });
      test('currentRoute 初始为 null', () {
        expect(controller.currentRoute, isNull);
      });
    });

    group('startPiP', () {
      test('调用后 isActive 变为 true', () async {
        await controller.startPiP('player');
        expect(controller.isActive, isTrue);
      });
      test('调用后 currentRoute 被设置', () async {
        await controller.startPiP('player');
        expect(controller.currentRoute, equals('player'));
      });
      test('调用后触发 onPiPStarted 回调', () async {
        var called = false;
        controller.onPiPStarted = () => called = true;
        await controller.startPiP('player');
        expect(called, isTrue);
      });
    });

    group('stopPiP', () {
      test('调用后 isActive 变为 false', () async {
        await controller.startPiP('player');
        await controller.stopPiP();
        expect(controller.isActive, isFalse);
      });
      test('调用后触发 onPiPStopped 回调', () async {
        var called = false;
        controller.onPiPStopped = () => called = true;
        await controller.stopPiP();
        expect(called, isTrue);
      });
    });

    group('updateRoute', () {
      test('更新 currentRoute', () {
        controller.updateRoute('home');
        expect(controller.currentRoute, equals('home'));
      });
    });

    group('checkPiPSupported', () {
      test('返回 true 并设置 isSupported 当平台支持时', () async {
        final result = await controller.checkPiPSupported();
        expect(result, isTrue);
        expect(controller.isSupported, isTrue);
      });
    });

    group('Event Callbacks', () {
      test('onPiPStarted 回调不为 null', () {
        expect(controller.onPiPStarted, isNotNull);
      });
      test('onPiPStopped 回调不为 null', () {
        expect(controller.onPiPStopped, isNotNull);
      });
      test('onPiPError 回调不为 null', () {
        expect(controller.onPiPError, isNotNull);
      });
      test('onPiPError 回调可接收错误消息', () async {
        String? receivedError;
        controller.onPiPError = (msg) => receivedError = msg;
        controller.onPiPError?.call('test error');
        expect(receivedError, equals('test error'));
      });
    });
  });
}
