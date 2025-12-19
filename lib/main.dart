import 'package:beariscope/pages/auth/welcome_page.dart';
import 'package:beariscope/pages/corrections/corrections_page.dart';
import 'package:beariscope/pages/drive_team/drive_team_page.dart';
import 'package:beariscope/pages/picklists/picklists_create_page.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_home_page.dart';
import 'package:beariscope/pages/up_next/up_next_page.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/picklists/picklists_page.dart';
import 'package:beariscope/pages/settings/about_settings_page.dart';
import 'package:beariscope/pages/settings/account_settings_page.dart';
import 'package:beariscope/pages/settings/appearance_settings_page.dart';
import 'package:beariscope/pages/settings/manage_team_page.dart';
import 'package:beariscope/pages/settings/notifications_settings_page.dart';
import 'package:beariscope/pages/settings/settings_page.dart';
import 'package:beariscope/pages/team_lookup/team_lookup_page.dart';
import 'package:beariscope/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart';
import 'package:beariscope/utils/window_size_stub.dart'
    if (dart.library.io) 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  setUrlStrategy(PathUrlStrategy());

  await initHiveForFlutter();

  if (PlatformUtils.isDesktop()) {
    setWindowMinSize(const Size(500, 600));
    setWindowMaxSize(Size.infinite);
    setWindowTitle('Beariscope');
  }

  runApp(const ProviderScope(child: Beariscope()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: '/up_next',
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
      ShellRoute(
        builder: (_, _, child) => MainView(child: child),
        routes: [
          GoRoute(
            path: '/up_next',
            pageBuilder: (_, _) => const NoTransitionPage(child: UpNextPage()),
          ),
          GoRoute(
            path: '/team_lookup',
            pageBuilder:
                (_, _) => const NoTransitionPage(child: TeamLookupPage()),
          ),
          GoRoute(
            path: '/picklists',
            pageBuilder:
                (_, _) => const NoTransitionPage(child: PicklistsPage()),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, _) => const PicklistsCreatePage(),
              ),
            ],
          ),
          GoRoute(
            path: '/drive_team',
            pageBuilder:
                (_, _) => const NoTransitionPage(child: DriveTeamHomePage()),
          ),
          GoRoute(
            path: '/corrections',
            pageBuilder:
                (_, _) => const NoTransitionPage(child: CorrectionsPage()),
          ),
          GoRoute(
            path: '/pits_scouting',
            pageBuilder:
                (_, _) => const NoTransitionPage(child: PitsScoutingHomePage()),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'account',
            builder: (_, _) => const AccountSettingsPage(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (_, _) => const NotificationsSettingsPage(),
          ),
          GoRoute(
            path: 'appearance',
            builder: (_, _) => const AppearanceSettingsPage(),
          ),
          GoRoute(path: 'about', builder: (_, _) => const AboutSettingsPage()),
          GoRoute(
            path: 'licenses',
            builder: (_, _) {
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
            builder: (_, state) {
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
      final isWelcomePage = location == '/welcome';

      // do nothing while authing
      if (authStatus == AuthStatus.authenticating) {
        return null;
      }

      // go to welcome if not authed
      if (authStatus == AuthStatus.unauthenticated) {
        return isWelcomePage ? null : '/welcome';
      }

      // if on welcome and authed then leave
      if (authStatus == AuthStatus.authenticated && isWelcomePage) {
        return '/up_next';
      }

      return null;
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
      ref.read(authStatusProvider.notifier).setAuthenticating();
      await ref.read(authProvider).trySilentLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authStatus = ref.watch(authStatusProvider);

    // Show loading screen while authenticating
    if (authStatus == AuthStatus.authenticating) {
      return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

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
