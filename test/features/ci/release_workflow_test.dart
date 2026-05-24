import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';

void main() {
  group('Release Workflow CI', () {
    test('release workflow has correct permissions', () {
      final workflowFile = File('.github/workflows/release.yml');
      expect(workflowFile.existsSync(), isTrue);

      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      // Verify permissions are set
      expect(yaml['permissions'], isNotNull);
      expect(yaml['permissions']['contents'], equals('write'));
    });

    test('release workflow builds android APK', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      final hasAndroidBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Android APK' &&
        (step['run'] as String).contains('flutter build apk --release')
      );

      expect(hasAndroidBuild, isTrue);
    });

    test('release workflow builds web app', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      final hasWebBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Web App' &&
        (step['run'] as String).contains('flutter build web')
      );

      expect(hasWebBuild, isTrue);
    });

    test('release workflow uses softprops/action-gh-release@v2', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      final uploadStep = steps.firstWhere((step) =>
        step is YamlMap && step['name'] == 'Upload to GitHub Release'
      ) as YamlMap;

      final uses = uploadStep['uses'] as String;
      expect(uses, equals('softprops/action-gh-release@v2'));
    });

    test('release workflow uploads both APK and web zip', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      final uploadStep = steps.firstWhere((step) =>
        step is YamlMap && step['name'] == 'Upload to GitHub Release'
      ) as YamlMap;

      // files is inside 'with' block
      final withBlock = uploadStep['with'] as YamlMap;
      final filesStr = withBlock['files']?.toString() ?? '';

      expect(filesStr, contains('app-release.apk'));
      expect(filesStr, contains('whitetv-web.zip'));
    });
  });
}