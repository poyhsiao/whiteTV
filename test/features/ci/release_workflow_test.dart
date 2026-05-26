import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';

void main() {
  group('Release Workflow CI', () {
    late YamlMap yaml;

    setUp(() {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      yaml = loadYaml(content) as YamlMap;
    });

    test('release workflow has correct permissions', () {
      expect(yaml['permissions'], isNotNull);
      expect(yaml['permissions']['contents'], equals('write'));
    });

    test('release workflow has android, macos, ios, and release jobs', () {
      final jobs = yaml['jobs'] as YamlMap;
      expect(jobs.containsKey('android'), isTrue);
      expect(jobs.containsKey('macos'), isTrue);
      expect(jobs.containsKey('ios'), isTrue);
      expect(jobs.containsKey('release'), isTrue);
    });

    test('release workflow has android job with mobile APK build', () {
      final jobs = yaml['jobs'] as YamlMap;
      final androidJob = jobs['android'] as YamlMap;
      final steps = androidJob['steps'] as YamlList;

      final hasMobileBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Mobile/Pad APK' &&
        (step['run'] as String).contains('--target-platform android-arm')
      );

      expect(hasMobileBuild, isTrue);
    });

    test('release workflow has android job with TV APK build', () {
      final jobs = yaml['jobs'] as YamlMap;
      final androidJob = jobs['android'] as YamlMap;
      final steps = androidJob['steps'] as YamlList;

      final hasTVBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build TV APK' &&
        (step['run'] as String).contains('--target-platform android-arm64')
      );

      expect(hasTVBuild, isTrue);
    });

    test('release workflow has android job with web app build', () {
      final jobs = yaml['jobs'] as YamlMap;
      final androidJob = jobs['android'] as YamlMap;
      final steps = androidJob['steps'] as YamlList;

      final hasWebBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Web App' &&
        (step['run'] as String).contains('flutter build web')
      );

      expect(hasWebBuild, isTrue);
    });

    test('release workflow has macos job', () {
      final jobs = yaml['jobs'] as YamlMap;
      final macosJob = jobs['macos'] as YamlMap;
      expect(macosJob['runs-on'], equals('macos-latest'));
    });

    test('release workflow has ios job', () {
      final jobs = yaml['jobs'] as YamlMap;
      final iosJob = jobs['ios'] as YamlMap;
      expect(iosJob['runs-on'], equals('macos-latest'));
    });

    test('release workflow has release job that depends on all build jobs', () {
      final jobs = yaml['jobs'] as YamlMap;
      final releaseJob = jobs['release'] as YamlMap;
      final needs = releaseJob['needs'] as YamlList;
      expect(needs.map((e) => e.toString()), containsAll(['android', 'macos', 'ios']));
    });

    test('release workflow release job uses softprops/action-gh-release@v2', () {
      final jobs = yaml['jobs'] as YamlMap;
      final releaseJob = jobs['release'] as YamlMap;
      final steps = releaseJob['steps'] as YamlList;

      final uploadStep = steps.firstWhere((step) =>
        step is YamlMap && step['name'] == 'Upload to GitHub Release'
      ) as YamlMap;

      final uses = uploadStep['uses'] as String;
      expect(uses, equals('softprops/action-gh-release@v2'));
    });

    test('release workflow extracts version from git tag in android job', () {
      final jobs = yaml['jobs'] as YamlMap;
      final androidJob = jobs['android'] as YamlMap;
      final steps = androidJob['steps'] as YamlList;

      final hasVersionStep = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Extract version' &&
        (step['run'] as String?)?.contains('VERSION=') == true
      );

      expect(hasVersionStep, isTrue);
    });

    test('release workflow has FLUTTER_VERSION environment variable', () {
      expect(yaml['env'], isNotNull);
      expect(yaml['env']['FLUTTER_VERSION'], equals('3.44.0'));
    });
  });
}
