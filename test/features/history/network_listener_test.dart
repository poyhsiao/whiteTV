import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/history/services/network_listener.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkListener', () {
    late MockConnectivity mockConnectivity;
    late StreamController<List<ConnectivityResult>> controller;
    late NetworkListener listener;
    late bool callbackCalled;
    late int callbackCount;

    setUp(() {
      mockConnectivity = MockConnectivity();
      controller = StreamController<List<ConnectivityResult>>.broadcast();
      callbackCalled = false;
      callbackCount = 0;

      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);
    });

    tearDown(() {
      listener.dispose();
      controller.close();
    });

    test('callback is called when network restored', () async {
      listener = NetworkListener(
        connectivity: mockConnectivity,
        onRestored: () async {
          callbackCalled = true;
          callbackCount++;
        },
      );

      // Simulate going offline first
      controller.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero);

      expect(callbackCalled, isFalse);

      // Simulate coming back online
      controller.add([ConnectivityResult.wifi]);
      await Future.delayed(Duration.zero);

      expect(callbackCalled, isTrue);
      expect(callbackCount, 1);
    });

    test('callback not called when going offline only', () async {
      listener = NetworkListener(
        connectivity: mockConnectivity,
        onRestored: () async {
          callbackCalled = true;
          callbackCount++;
        },
      );

      // Simulate going offline
      controller.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero);

      // Callback should NOT be called when going offline
      expect(callbackCalled, isFalse);
      expect(callbackCount, 0);

      // Stay offline - no callback
      controller.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero);

      expect(callbackCalled, isFalse);
      expect(callbackCount, 0);
    });

    test('callback not called on initial state', () async {
      var initCallback = false;
      listener = NetworkListener(
        connectivity: mockConnectivity,
        onRestored: () async {
          initCallback = true;
        },
      );

      // Initial state should not trigger callback
      await Future.delayed(Duration.zero);

      expect(initCallback, isFalse);
    });
  });
}