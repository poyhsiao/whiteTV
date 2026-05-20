import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SettingsStorageService service;
  late SharedPreferences prefs;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockSecureStorage = MockFlutterSecureStorage();

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SettingsStorageService(prefs, mockSecureStorage);
  });

  group('LunaTV URL', () {
    test('saveLunaTVUrl stores URL in prefs', () async {
      await service.saveLunaTVUrl('https://lunatv.example.com');
      final result = await service.getLunaTVUrl();
      expect(result, 'https://lunatv.example.com');
    });

    test('getLunaTVUrl returns null when not set', () async {
      final result = await service.getLunaTVUrl();
      expect(result, isNull);
    });
  });

  group('Theme Mode', () {
    test('saveThemeMode stores mode in prefs', () async {
      await service.saveThemeMode('light');
      final result = await service.getThemeMode();
      expect(result, 'light');
    });

    test('getThemeMode returns dark when not set', () async {
      final result = await service.getThemeMode();
      expect(result, 'dark');
    });
  });

  group('Auto Play', () {
    test('saveAutoPlay stores boolean in prefs', () async {
      await service.saveAutoPlay(false);
      final result = await service.getAutoPlay();
      expect(result, false);
    });

    test('getAutoPlay returns true when not set', () async {
      final result = await service.getAutoPlay();
      expect(result, true);
    });
  });

  group('Default Quality', () {
    test('saveDefaultQuality stores quality in prefs', () async {
      await service.saveDefaultQuality('1080p');
      final result = await service.getDefaultQuality();
      expect(result, '1080p');
    });

    test('getDefaultQuality returns auto when not set', () async {
      final result = await service.getDefaultQuality();
      expect(result, 'auto');
    });
  });

  group('Auto Select Source', () {
    test('saveAutoSelectSource stores boolean in prefs', () async {
      await service.saveAutoSelectSource(false);
      final result = await service.getAutoSelectSource();
      expect(result, false);
    });

    test('getAutoSelectSource returns true when not set', () async {
      final result = await service.getAutoSelectSource();
      expect(result, true);
    });
  });

  group('Blocked Sources', () {
    test('saveBlockedSources stores list in prefs', () async {
      await service.saveBlockedSources(['source1', 'source2']);
      final result = await service.getBlockedSources();
      expect(result, ['source1', 'source2']);
    });

    test('getBlockedSources returns empty list when not set', () async {
      final result = await service.getBlockedSources();
      expect(result, isEmpty);
    });
  });

  group('Home Blocks', () {
    test('saveHomeBlocks stores each block individually', () async {
      final blocks = {
        'showRecentWatch': false,
        'showLive': true,
        'showCategories': true,
        'showAIRecommend': false,
        'showHotMovies': true,
      };
      await service.saveHomeBlocks(blocks);

      expect(prefs.getBool('home_blocks_showRecentWatch'), false);
      expect(prefs.getBool('home_blocks_showLive'), true);
      expect(prefs.getBool('home_blocks_showCategories'), true);
      expect(prefs.getBool('home_blocks_showAIRecommend'), false);
      expect(prefs.getBool('home_blocks_showHotMovies'), true);
    });

    test('getHomeBlocks returns all defaults when not set', () async {
      final result = await service.getHomeBlocks();
      expect(result, {
        'showRecentWatch': true,
        'showLive': true,
        'showCategories': true,
        'showAIRecommend': true,
        'showHotMovies': true,
      });
    });
  });

  group('Tab Order', () {
    test('saveTabOrder stores list in prefs', () async {
      await service.saveTabOrder(['search', 'home', 'live']);
      final result = await service.getTabOrder();
      expect(result, ['search', 'home', 'live']);
    });

    test('getTabOrder returns default order when not set', () async {
      final result = await service.getTabOrder();
      expect(
        result,
        ['home', 'categories', 'live', 'search', 'favorites', 'settings'],
      );
    });
  });

  group('Username', () {
    test('saveUsername stores username in prefs', () async {
      await service.saveUsername('testuser');
      final result = await service.getUsername();
      expect(result, 'testuser');
    });

    test('saveUsername with null removes username', () async {
      await service.saveUsername('testuser');
      await service.saveUsername(null);
      final result = await service.getUsername();
      expect(result, isNull);
    });

    test('getUsername returns null when not set', () async {
      final result = await service.getUsername();
      expect(result, isNull);
    });
  });

  group('Auth Cookie (Secure Storage)', () {
    test('saveAuthCookie stores cookie in secure storage', () async {
      when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'session123');

      await service.saveAuthCookie('session123');
      final result = await service.getAuthCookie();
      expect(result, 'session123');
    });

    test('getAuthCookie returns null when not set', () async {
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await service.getAuthCookie();
      expect(result, isNull);
    });

    test('clearAuthCookie removes cookie from secure storage', () async {
      when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      await service.saveAuthCookie('session123');
      await service.clearAuthCookie();
      final result = await service.getAuthCookie();
      expect(result, isNull);
    });
  });
}