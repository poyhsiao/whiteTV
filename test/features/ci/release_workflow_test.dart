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

    test('release workflow has android and macos jobs (publish is separate workflow)', () {
      final jobs = yaml['jobs'] as YamlMap;
      expect(jobs.containsKey('android'), isTrue);
      expect(jobs.containsKey('macos'), isTrue);
      // iOS job is disabled - requires Apple certificates not available in standard CI
      // publish job is in create_release.yml, not release.yml
    });

    test('release workflow has android job with APK build step', () {
      final jobs = yaml['jobs'] as YamlMap;
      final androidJob = jobs['android'] as YamlMap;
      final steps = androidJob['steps'] as YamlList;

      // 實際 step 名稱是 'Build Android APK'，包含 apk build
      final hasApkBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Android APK' &&
        (step['run'] as String?)?.contains('apk') == true
      );
      expect(hasApkBuild, isTrue);
    });

    test('release workflow has android job with web build step', () {
      final jobs = yaml['jobs'] as YamlMap;
      final androidJob = jobs['android'] as YamlMap;
      final steps = androidJob['steps'] as YamlList;

      // 實際 step 名稱是 'Build Web'
      final hasWebBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Web' &&
        (step['run'] as String?)?.contains('web') == true
      );
      expect(hasWebBuild, isTrue);
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

    test('release workflow has concurrency settings', () {
      expect(yaml['concurrency'], isNotNull);
      expect(yaml['concurrency']['group'], isNotNull);
      expect(yaml['concurrency']['cancel-in-progress'], isNotNull);
    });

    test('release workflow triggers on tag push and workflow dispatch', () {
      final on = yaml['on'];
      expect(on, isNotNull);
      // on: can be YamlList or YamlMap depending on structure
      if (on is YamlMap) {
        expect(on.containsKey('push'), isTrue);
        expect(on.containsKey('workflow_dispatch'), isTrue);
      }
    });
  });
}
