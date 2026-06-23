import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/features/category/category_screen.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/history/history_screen.dart';
import 'package:white_tv/features/home/home_screen.dart';
import 'package:white_tv/features/live/presentation/screens/live_player_screen.dart';
import 'package:white_tv/features/live/presentation/screens/live_screen.dart';
import 'package:white_tv/features/login/presentation/screens/login_screen.dart';
import 'package:white_tv/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:white_tv/features/player/player_screen.dart';
import 'package:white_tv/features/search/search_screen.dart';
import 'package:white_tv/features/settings/presentation/screens/remote_guide_screen.dart';
import 'package:white_tv/features/settings/settings_screen.dart';
import 'package:white_tv/features/youtube/presentation/screens/youtube_category_screen.dart';

/// GoRouter configuration
/// Routes: / (home), /detail/:id, /player/:id/:episodeId

final _routeList = <GoRoute>[
  GoRoute(
    path: '/',
    name: 'home',
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/detail/:id',
    name: 'detail',
    builder: (context, state) {
      final videoId = state.pathParameters['id']!;
      return DetailScreen(videoId: videoId);
    },
  ),
  GoRoute(
    path: '/player/:id/:episodeId',
    name: 'player',
    builder: (context, state) {
      final videoId = state.pathParameters['id']!;
      final episodeId = state.pathParameters['episodeId']!;
      return PlayerScreen(videoId: videoId, episodeId: episodeId);
    },
  ),
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => LoginScreen(
      onLoginComplete: (success) {
        if (success && context.mounted) {
          context.go('/');
        }
      },
    ),
  ),
  GoRoute(
    path: '/remote-guide',
    name: 'remote-guide',
    builder: (context, state) => const RemoteGuideScreen(),
  ),
  GoRoute(
    path: '/onboarding',
    name: 'onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),
  GoRoute(
    path: '/settings',
    name: 'settings',
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: '/search',
    name: 'search',
    builder: (context, state) => const SearchScreen(),
  ),
  GoRoute(
    path: '/history',
    name: 'history',
    builder: (context, state) => const HistoryScreen(),
  ),
  GoRoute(
    path: '/live',
    name: 'live',
    builder: (context, state) => const LiveScreen(),
    routes: [
      GoRoute(
        path: 'player',
        name: 'live-player',
        builder: (context, state) => const LivePlayerScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/category/:id',
    name: 'category-content',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      if (id == 'youtube') {
        return const YoutubeCategoryScreen();
      }
      return CategoryScreen(categoryId: id);
    },
  ),
  // TODO(Task14): Replace with full YouTube player screen
  GoRoute(
    path: '/youtube/:id',
    name: 'youtube-player',
    builder: (context, state) {
      final videoId = state.pathParameters['id']!;
      return Scaffold(
        appBar: AppBar(title: const Text('YouTube')),
        body: Center(
          child: Text('YouTube video: $videoId (placeholder)'),
        ),
      );
    },
  ),
];

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: _routeList,
  );
}

final appRouter = createAppRouter();
