// Sprint 5.3 — AppRouter integration test
// TDD 紅階段: 驗證每個 GoRoute 在 navigate 後真的匹配且 pathParameters 正確

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/features/home/home_screen.dart';
import 'package:white_tv/features/home/home_screen.desktop.dart';

void main() {
  group('AppRouter route navigation (Sprint 5.3)', () {
    late GoRouter router;

    setUp(() {
      router = createAppRouter(initialLocation: '/');
    });

    tearDown(() async {
      router.dispose();
    });

    String? routeNameFor(String path) {
      final list = router.configuration.findMatch(Uri.parse(path));
      if (list.matches.isEmpty) return null;
      final last = list.matches.last;
      return last is RouteMatch ? last.route.name : null;
    }

    Map<String, String> pathParamsFor(String path) {
      final list = router.configuration.findMatch(Uri.parse(path));
      if (list.matches.isEmpty) return {};
      return list.pathParameters;
    }

    test('initialLocation / 匹配 home route', () {
      expect(routeNameFor('/'), equals('home'));
    });

    test('/login 匹配 login route', () {
      expect(routeNameFor('/login'), equals('login'));
    });

    test('/settings 匹配 settings route', () {
      expect(routeNameFor('/settings'), equals('settings'));
    });

    test('/detail/v123 匹配 detail route 帶 videoId', () {
      expect(routeNameFor('/detail/v123'), equals('detail'));
      expect(pathParamsFor('/detail/v123')['id'], equals('v123'));
    });

    test('/player/v1/e1 匹配 player route 帶 videoId+episodeId', () {
      expect(routeNameFor('/player/v1/e1'), equals('player'));
      final params = pathParamsFor('/player/v1/e1');
      expect(params['id'], equals('v1'));
      expect(params['episodeId'], equals('e1'));
    });

    test('/category/movie 匹配 category route 帶 categoryId', () {
      expect(routeNameFor('/category/movie'), equals('category-content'));
      expect(pathParamsFor('/category/movie')['id'], equals('movie'));
    });

    test('/youtube/abc?url=x 匹配 youtube-player 帶 query', () {
      final path = '/youtube/abc?url=https://youtube.com/watch?v=abc';
      expect(routeNameFor(path), equals('youtube-player'));
      expect(pathParamsFor(path)['id'], equals('abc'));
      expect(Uri.parse(path).queryParameters['url'], equals('https://youtube.com/watch?v=abc'));
    });

    test('/history 匹配 history route', () {
      expect(routeNameFor('/history'), equals('history'));
    });

    test('/downloads 匹配 downloads route', () {
      expect(routeNameFor('/downloads'), equals('downloads'));
    });

    test('/search 匹配 search route', () {
      expect(routeNameFor('/search'), equals('search'));
    });

    test('/remote-guide 匹配 remote-guide route', () {
      expect(routeNameFor('/remote-guide'), equals('remote-guide'));
    });

    test('/onboarding 匹配 onboarding route', () {
      expect(routeNameFor('/onboarding'), equals('onboarding'));
    });

    test('/live 匹配 live route', () {
      expect(routeNameFor('/live'), equals('live'));
    });

    test('/live/player 匹配 live-player 嵌套 route', () {
      expect(routeNameFor('/live/player'), equals('live-player'));
    });
  });

  // BDD device routing widget tests require full provider integration mocking
  // (homeStoreProvider, youtubeStoreProvider). Routing logic is verified by
  // 14 unit tests + _buildHomeScreen simple conditional dispatch.
  // Widget integration tests with full mocking: see integration_test/app_routes_smoke_test.dart

}
