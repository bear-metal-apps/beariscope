// lib/main.dart
import 'package:beariscope/pages/analytics/analytics_page.dart';
import 'package:beariscope/pages/auth/welcome_page.dart';
import 'package:beariscope/pages/home/home_page.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/scout/scout_page.dart';
import 'package:beariscope/pages/settings/about_settings_page.dart';
import 'package:beariscope/pages/settings/account_settings_page.dart';
import 'package:beariscope/pages/settings/appearance_settings_page.dart';
import 'package:beariscope/pages/settings/manage_team_page.dart';
import 'package:beariscope/pages/settings/notifications_settings_page.dart';
import 'package:beariscope/pages/settings/settings_page.dart';
import 'package:beariscope/pages/teams/teams_page.dart';
import 'package:beariscope/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart';
import 'package:beariscope/utils/window_size_stub.dart'
    if (dart.library.io) 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  setUrlStrategy(PathUrlStrategy());

  if (PlatformUtils.isDesktop()) {
    setWindowMinSize(const Size(450, 640));
    setWindowMaxSize(Size.infinite);
    setWindowTitle('Beariscope');
  }

  runApp(const ProviderScope(child: Beariscope()));
}

// Makes the router refresh when auth status changes
class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final _authRouterNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();
  ref.onDispose(notifier.dispose);

  ref.listen<AuthStatus>(authStatusProvider, (prev, next) {
    if (prev != next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.refresh());
    }
  });
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);
  final authListenable = ref.watch(_authRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    routes: <RouteBase>[
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/',
        builder:
            (context, state) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainView(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder:
                (context, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/teams',
            pageBuilder:
                (context, state) => const NoTransitionPage(child: TeamsPage()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: AnalyticsPage()),
          ),
          GoRoute(
            path: '/scout',
            pageBuilder:
                (context, state) => const NoTransitionPage(child: ScoutPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'account',
            builder: (context, state) {
              return const AccountSettingsPage();
            },
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) {
              return const NotificationsSettingsPage();
            },
          ),
          GoRoute(
            path: 'appearance',
            builder: (context, state) {
              return const AppearanceSettingsPage();
            },
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) {
              return const AboutSettingsPage();
            },
          ),
          GoRoute(
            path: 'licenses',
            builder: (context, state) {
              return FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '...';
                  return LicensePage(
                    applicationName: 'Beariscope',
                    applicationVersion: version,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'manage_team/:teamId',
            builder: (context, state) {
              final teamId = state.pathParameters['teamId'] ?? '';
              return teamId.isEmpty
                  ? const Center(child: Text('Team ID is empty'))
                  : ManageTeamPage(teamId: teamId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;

      switch (authStatus) {
        case AuthStatus.unauthenticated:
          return location != '/welcome' ? '/welcome' : null;
        case AuthStatus.authenticating:
          return (location == '/welcome' || location == '/') ? null : '/';
        case AuthStatus.authenticated:
          return (location == '/' || location == '/welcome') ? '/home' : null;
      }
    },
  );
});

class Beariscope extends ConsumerStatefulWidget {
  const Beariscope({super.key});

  @override
  ConsumerState<Beariscope> createState() => _BeariscopeState();
}

class _BeariscopeState extends ConsumerState<Beariscope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authStatusNotifier = ref.read(authStatusProvider.notifier);
      authStatusNotifier.state = AuthStatus.authenticating;
      try {
        final response = await ref.read(authProvider).refresh();
        authStatusNotifier.state =
            response == null
                ? AuthStatus.unauthenticated
                : AuthStatus.authenticated;
      } catch (_) {
        authStatusNotifier.state = AuthStatus.unauthenticated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        iconTheme: const IconThemeData(fill: 0.0, weight: 600),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(fill: 0.0, weight: 600),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
