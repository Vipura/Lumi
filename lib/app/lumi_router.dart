import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/lumi_design_gallery_screen.dart';
import '../data/repositories/providers.dart';
import '../features/calm_space/calm_space_screen.dart';
import '../features/checklists/checklists_screen.dart';
import '../features/editor/note_editor_screen.dart';
import '../features/notes/archive_trash_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/planner_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sticky_wall/sticky_wall_screen.dart';
import '../features/today/today_screen.dart';
import 'lumi_shell.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final lumiRouterProvider = Provider<GoRouter>((ref) {
  final navKey = GlobalKey<NavigatorState>();
  rootNavigatorKey = navKey;

  final onboardingDone = ref
      .read(settingsControllerProvider)
      .onboardingCompleted;

  return GoRouter(
    navigatorKey: navKey,
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
              GoRoute(
                path: '/checklists',
                builder: (_, _) => const ChecklistsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reminders',
                builder: (_, _) => const RemindersScreen(),
              ),
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
        path: '/calm',
        parentNavigatorKey: navKey,
        builder: (_, _) => const CalmSpaceScreen(),
      ),
      GoRoute(
        path: '/calm/:id',
        parentNavigatorKey: navKey,
        builder: (_, state) =>
            CalmSpaceScreen(entryId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/editor/:id',
        parentNavigatorKey: navKey,
        builder: (_, state) => NoteEditorScreen(
          itemId: state.pathParameters['id']!,
          heroPrefix: state.uri.queryParameters['hero'],
        ),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: navKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: navKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/archive',
        parentNavigatorKey: navKey,
        builder: (_, _) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/trash',
        parentNavigatorKey: navKey,
        builder: (_, _) => const TrashScreen(),
      ),
      GoRoute(
        path: '/design-gallery',
        parentNavigatorKey: navKey,
        builder: (context, _) => LumiDesignGalleryScreen(
          initialBrightness: Theme.of(context).brightness,
        ),
      ),
    ],
  );
});
