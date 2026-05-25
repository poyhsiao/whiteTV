import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/device_utils.dart';

void main() {
  group('DeviceUtils', () {
    testWidgets('returns tv for width >= 1024 and < 1200', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1100, 1080)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.getDeviceType(context), DeviceType.tv);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns desktop for width >= 1200', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1440, 900)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.getDeviceType(context), DeviceType.desktop);
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
          data: const MediaQueryData(size: Size(1100, 1080)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.isTV(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('isDesktop returns correct value for large width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1440, 900)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.isDesktop(context), isTrue);
              expect(DeviceUtils.isTV(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('needsMouseSupport returns true for desktop', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1440, 900)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.needsMouseSupport(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('needsMouseSupport returns true for tablet', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              expect(DeviceUtils.needsMouseSupport(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}