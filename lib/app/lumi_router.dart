import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/lumi_design_gallery_screen.dart';
import '../data/repositories/providers.dart';
import '../features/editor/note_editor_screen.dart';
import '../features/notes/archive_trash_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/planner_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sticky_wall/sticky_wall_screen.dart';
import '../features/today/today_screen.dart';
import 'lumi_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final lumiRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref
      .read(settingsControllerProvider)
      .onboardingCompleted;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboardingDone ? '/today' : '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            LumiShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/plan', builder: (_, _) => const PlannerScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wall',
                builder: (_, _) => const StickyWallScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/editor/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => NoteEditorScreen(
          itemId: state.pathParameters['id']!,
          heroPrefix: state.uri.queryParameters['hero'],
        ),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/archive',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/trash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const TrashScreen(),
      ),
      GoRoute(
        path: '/design-gallery',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, _) => LumiDesignGalleryScreen(
          initialBrightness: Theme.of(context).brightness,
        ),
      ),
    ],
  );
});
