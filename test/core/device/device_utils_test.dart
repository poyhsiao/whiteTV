import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_utils.dart';

void main() {
  group('DeviceUtils', () {
    testWidgets('returns tv for width >= 1024', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1920, 1080)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.getDeviceType(context), DeviceType.tv);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns tablet for width 768-1023', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.getDeviceType(context), DeviceType.tablet);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns mobile for width < 768', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(375, 812)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.getDeviceType(context), DeviceType.mobile);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('isTV returns correct value', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1920, 1080)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.isTV(context), isTrue);
              expect(DeviceUtils.isMobile(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}