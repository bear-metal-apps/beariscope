import 'dart:ui';

import 'package:bearscout/pages/auth/login_page.dart';
import 'package:bearscout/pages/auth/signup_page.dart';
import 'package:bearscout/pages/main_view.dart';
import 'package:bearscout/pages/auth/welcome_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  Logger logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(''),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Get SharedPreferences here
  final sharedPreferences = await SharedPreferences.getInstance();

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      logger.i('User is signed out!');
      await sharedPreferences.setBool('isLoggedIn', false);
    } else {
      logger.i('User is signed in!');
      await sharedPreferences.setBool('isLoggedIn', true);
    }
  });

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
              return const SignupPage();
            },
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
      final bool atRoot = state.matchedLocation == '/';
      if (atRoot) {
        return loggedIn ? '/home' : '/welcome';
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
