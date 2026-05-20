import 'package:go_router/go_router.dart';
import 'package:white_tv/features/home/home_screen.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/player/player_screen.dart';
import 'package:white_tv/features/settings/settings_screen.dart';

/// GoRouter configuration
/// Routes: / (home), /detail/:id, /player/:id/:episodeId

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
