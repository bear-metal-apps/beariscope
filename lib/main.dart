import 'package:appwrite/appwrite.dart';
import 'package:beariscope/pages/auth/sign_in_page.dart';
import 'package:beariscope/pages/auth/signup_page.dart';
import 'package:beariscope/pages/auth/welcome_page.dart';
import 'package:beariscope/pages/data/data_page.dart';
import 'package:beariscope/pages/home/home_page.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/scout/scout_page.dart';
import 'package:beariscope/pages/user/create_team_page.dart';
import 'package:beariscope/pages/user/join_team_page.dart';
import 'package:beariscope/pages/user/manage_team_page.dart';
import 'package:beariscope/pages/user/settings_page.dart';
import 'package:beariscope/pages/user/user_page.dart';
import 'package:beariscope/providers/auth_provider.dart';
import 'package:beariscope/providers/team_provider.dart';
import 'package:beariscope/services/auth_service.dart';
import 'package:beariscope/services/team_service.dart';
import 'package:beariscope/utils/platform_utils_stub.dart' // if on web
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart'; // if on desktop or mobile
import 'package:beariscope/utils/window_size_stub.dart' // if on web/mobile
    if (dart.library.io) 'package:window_size/window_size.dart'; // if on desktop
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start Appwrite
  Client client = Client();
  client
      .setEndpoint('https://appwrite.bearmet.al/v1')
      .setProject('68391727001966068b86')
      .setSelfSigned(status: true); // only use for development

  final authService = AuthService(client: client);
  final teamService = TeamService(client: client);

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Don't use hash-based urls for web
  setUrlStrategy(PathUrlStrategy());

  if (PlatformUtils.isDesktop()) {
    setWindowMinSize(const Size(450, 640));
    setWindowMaxSize(Size.infinite);
    setWindowTitle('Beariscope');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<Client>.value(value: client),
        Provider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: authService),
        ),
        Provider<TeamService>(create: (_) => teamService),
        ChangeNotifierProvider<TeamProvider>(
          create: (_) => TeamProvider(teamService: teamService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context);
  }

  GoRouter createRouter(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/welcome',
          builder: (BuildContext context, GoRouterState state) {
            return const WelcomePage();
          },
          routes: [
            GoRoute(
              path: 'signin',
              builder: (BuildContext context, GoRouterState state) {
                return const SignInPage();
              },
            ),
            GoRoute(
              path: 'signup',
              builder: (BuildContext context, GoRouterState state) {
                return SignupPage();
              },
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => MainView(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return NoTransitionPage(child: const HomePage());
              },
            ),
            GoRoute(
              path: '/scout',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return NoTransitionPage(child: const ScoutPage());
              },
            ),
            GoRoute(
              path: '/data',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return NoTransitionPage(child: const DataPage());
              },
            ),
            GoRoute(
              path: '/you',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return NoTransitionPage(child: const UserPage());
              },
              routes: [
                GoRoute(
                  path: 'join_team',
                  builder: (BuildContext context, GoRouterState state) {
                    return const JoinTeamPage();
                  },
                ),
                GoRoute(
                  path: 'create_team',
                  builder: (BuildContext context, GoRouterState state) {
                    return const CreateTeamPage();
                  },
                ),
                GoRoute(
                  path: 'manage_team/:teamId',
                  builder: (BuildContext context, GoRouterState state) {
                    final teamId = state.pathParameters['teamId']!;
                    if (teamId.isEmpty) {
                      return const Center(child: Text('Team ID is empty'));
                    }
                    return ManageTeamPage(teamId: teamId);
                  },
                ),
                GoRoute(
                  path: 'settings',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SettingsPage();
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            // Loading screen shown while getting auth state
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthed;
        final isLoading = authProvider.isLoading;

        // Don't redirect while loading
        if (isLoading) return null;

        // If at root path, redirect based on if authed
        if (state.matchedLocation == '/') {
          return isAuthenticated ? '/home' : '/welcome';
        }

        // If authed but on welcome pages, go to home screen
        if (isAuthenticated && state.matchedLocation.startsWith('/welcome')) {
          return '/home';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.light,
        ),
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
      routerConfig: _router,
    );
  }
}
