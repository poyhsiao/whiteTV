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

    test('release workflow builds mobile/pad APK', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      final hasMobileBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build Mobile/Pad APK' &&
        (step['run'] as String).contains('--target-platform android-arm')
      );

      expect(hasMobileBuild, isTrue);
    });

    test('release workflow builds TV APK', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      final hasTVBuild = steps.any((step) =>
        step is YamlMap &&
        step['name'] == 'Build TV APK (Google TV/Android TV)' &&
        (step['run'] as String).contains('--target-platform android-arm64')
      );

      expect(hasTVBuild, isTrue);
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

    test('release workflow uploads correctly named APK variants and web archive', () {
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

      // Verify new naming convention: whitetv-vX.Y.Z-{platform}.{ext}
      expect(filesStr, contains('whitetv-v*-mobile.apk'));
      expect(filesStr, contains('whitetv-v*-tv.apk'));
      expect(filesStr, contains('whitetv-v*-web.tgz'));
    });

    test('release workflow extracts version from git tag', () {
      final workflowFile = File('.github/workflows/release.yml');
      final content = workflowFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final jobs = yaml['jobs'] as YamlMap;
      final buildJob = jobs['build'] as YamlMap;
      final steps = buildJob['steps'] as YamlList;

      // Look for step that sets VERSION from tag
      final hasVersionStep = steps.any((step) =>
        step is YamlMap &&
        (step['run'] as String?)?.contains('VERSION=') == true &&
        (step['run'] as String).contains('GITHUB_REF')
      );

      expect(hasVersionStep, isTrue);
    });
  });
}