import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/recordings/presentation/screens/recordings_screen.dart';
import '../features/complaints/presentation/screens/complaints_screen.dart';
import '../features/complaints/presentation/screens/complaint_creation_screen.dart';
import '../features/complaints/presentation/screens/manual_complaint_creation_screen.dart';
import '../features/complaints/presentation/screens/complaint_details_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/discarded_recordings_screen.dart';
import '../features/recordings/domain/entities/recording_item.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/recordings',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/recordings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordingsScreen(),
            ),
          ),
          GoRoute(
            path: '/complaints',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComplaintsScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'discarded',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const DiscardedRecordingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Sub-routes (outside ShellRoute for full-screen)
      GoRoute(
        path: '/complaints/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final recording = state.extra as RecordingItem;
          return ComplaintCreationScreen(recording: recording);
        },
      ),
      GoRoute(
        path: '/complaints/create-manual',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManualComplaintCreationScreen(),
      ),
      GoRoute(
        path: '/complaints/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ComplaintDetailsScreen(complaintId: id);
        },
      ),
    ],
  );
});

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/recordings')) return 1;
    if (location.startsWith('/complaints')) return 2;
    if (location.startsWith('/history')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
            case 1:
              context.go('/recordings');
            case 2:
              context.go('/complaints');
            case 3:
              context.go('/history');
            case 4:
              context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Recordings',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
