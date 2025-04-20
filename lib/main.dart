import 'package:appwrite/appwrite.dart';
import 'package:bearscout/pages/auth/login_page.dart';
import 'package:bearscout/pages/auth/register_team_page.dart';
import 'package:bearscout/pages/auth/team_selection_page.dart';
import 'package:bearscout/pages/auth/user_details_page.dart';
import 'package:bearscout/pages/auth/welcome_page.dart';
import 'package:bearscout/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Client client = Client();
  client
      .setEndpoint('https://nyc.cloud.appwrite.io/v1')
      .setProject('bear-scout')
      .setSelfSigned(status: true); // only use for development

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  final account = Account(client);
  try {
    final user = await account.get();
    sharedPreferences.setBool('isLoggedIn', true);
  } catch (e) {
    sharedPreferences.setBool('isLoggedIn', false);
  }

  runApp(
    Provider<SharedPreferences>.value(
      value: sharedPreferences,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/welcome',
    routes: <RouteBase>[
      GoRoute(
        path: '/welcome',
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomePage();
        },
        routes: [
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const LoginPage();
            },
          ),
          GoRoute(
            path: 'signup',
            builder: (BuildContext context, GoRouterState state) {
              return UserDetailsPage(client: Client());
            },
            routes: [
              GoRoute(
                path: 'register_team',
                builder: (BuildContext context, GoRouterState state) {
                  return const RegisterTeamPage();
                },
              ),
              GoRoute(
                path: 'select_team',
                builder: (BuildContext context, GoRouterState state) {
                  return const TeamSelectionPage();
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const MainView();
        },
      ),
    ],
    redirect: (context, state) {
      final bool loggedIn =
          context.read<SharedPreferences>().getBool('isLoggedIn') ?? false;
      if (state.matchedLocation.startsWith('/welcome') && loggedIn) {
        return '/home';
      }
      return null;
    },
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(fill: 0.0, weight: 600),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(fill: 0.0, weight: 600),
      ),
      themeMode: ThemeMode.system,
      routerConfig: MyApp._router,
    );
  }
}
