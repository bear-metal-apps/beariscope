import 'package:beariscope/pages/auth/splash_screen.dart';
import 'package:beariscope/pages/auth/welcome_page.dart';
import 'package:beariscope/pages/auth/post_sign_in_onboarding_page.dart';
import 'package:beariscope/pages/corrections/corrections_page.dart';
import 'package:beariscope/providers/post_sign_in_flow_provider.dart';
import 'package:beariscope/pages/settings/scout_selection_page.dart';
import 'package:beariscope/pages/up_next/match_preview_page.dart';
import 'package:beariscope/pages/picklists/picklists_create_page.dart';
import 'package:beariscope/pages/picklists/picklists_teams.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_home_page.dart';
import 'package:beariscope/pages/up_next/up_next_page.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/picklists/picklists_page.dart';
import 'package:beariscope/pages/settings/about_settings_page.dart';
import 'package:beariscope/pages/settings/account_settings_page.dart';
import 'package:beariscope/pages/settings/appearance_settings_page.dart';
import 'package:beariscope/pages/settings/notifications_settings_page.dart';
import 'package:beariscope/pages/settings/settings_page.dart';
import 'package:beariscope/pages/team_lookup/team_lookup_page.dart';
import 'package:beariscope/pages/utilities/utilities_page.dart';
import 'package:beariscope/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart';
import 'package:beariscope/utils/window_size_stub.dart'
    if (dart.library.io) 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:libkoala/libkoala.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beariscope/pages/settings/team_role.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  setUrlStrategy(PathUrlStrategy());

  await Hive.initFlutter();
  await Hive.openBox('api_cache');

  if (PlatformUtils.isDesktop()) {
    setWindowMinSize(const Size(500, 600));
    setWindowMaxSize(Size.infinite);
    setWindowTitle('Beariscope');
  }

  runApp(
    ProviderScope(
      overrides: [
        auth0ConfigProvider.overrideWith((ref) {
          return const Auth0Config(
            domain: 'bearmetal2046.us.auth0.com',
            clientId: 'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
            audience: 'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
            redirectUris: {
              DeviceOS.ios: 'org.tahomarobotics.beariscope://callback',
              DeviceOS.macos: 'org.tahomarobotics.beariscope://callback',
              DeviceOS.android: 'org.tahomarobotics.beariscope://callback',
              DeviceOS.web: 'https://scout.bearmet.al/auth.html',
              DeviceOS.windows: 'http://localhost:4000/auth',
              DeviceOS.linux: 'http://localhost:4000/auth',
            },
            storageKeyPrefix: 'beariscope_',
          );
        }),
      ],
      child: const Beariscope(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authStatus,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
      GoRoute(
        path: '/post_sign_in_onboarding',
        builder: (_, _) => const PostSignInOnboardingPage(),
      ),
      ShellRoute(
        builder: (_, _, child) => MainView(child: child),
        routes: [
          GoRoute(
            path: '/up_next',
            pageBuilder: (_, _) => const NoTransitionPage(child: UpNextPage()),
            routes: [
              GoRoute(
                path: ':matchKey',
                builder: (context, state) {
                  final matchKey = state.pathParameters['matchKey'] ?? '1';
                  return DriveTeamMatchPreviewPage(matchKey: matchKey);
                },
              ),
            ],
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
              GoRoute(
                path: 'view',
                builder: (_, state) {
                  final picklist = state.extra as Map<String, dynamic>?;
                  return PicklistsTeamsPage(picklist: picklist);
                },
              ),
              GoRoute(path: 'roles', builder: (_, _) => const TeamRolesPage()),
              GoRoute(
                path: 'about',
                builder: (_, _) => const AboutSettingsPage(),
              ),
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
            ],
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
          GoRoute(
            path: '/utilities',
            pageBuilder:
                (_, _) => const NoTransitionPage(child: UtilitiesPage()),
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
          GoRoute(
            path: 'user_selection',
            builder: (_, _) => const ScoutSelectionPage(),
          ),
          GoRoute(path: 'roles', builder: (_, _) => const TeamRolesPage()),
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
        ],
      ),
    ],
    redirect: (_, state) {
      final auth = ref.watch(authStatusProvider);
      final location = state.matchedLocation;

      // splash while authing
      if (auth == AuthStatus.authenticating) {
        return location == '/splash' ? null : '/splash';
      }

      // go to welcome if not authed
      if (auth == AuthStatus.unauthenticated) {
        return location == '/welcome' ? null : '/welcome';
      }

      // if on welcome and authed then leave
      if (auth == AuthStatus.authenticated) {
        final pendingPostSignInFlow = ref.watch(postSignInFlowPendingProvider);
        if (pendingPostSignInFlow) {
          if (location != '/post_sign_in_onboarding') {
            return '/post_sign_in_onboarding';
          }
          return null;
        }

        final isRoleManagementRoute = location == '/settings/roles';
        final isScoutManagementRoute = location == '/settings/user_selection';
        final needsPermissions =
            isRoleManagementRoute ||
            isScoutManagementRoute;

        if (needsPermissions) {
          final authMe = ref.watch(authMeProvider);
          if (authMe.isLoading) {
            return location == '/splash' ? null : '/splash';
          }

          final checker = ref.watch(permissionCheckerProvider);

          if (isRoleManagementRoute) {
            final canManageRoles =
                checker?.hasPermission(PermissionKey.usersRolesManage) ?? false;
            if (!canManageRoles) {
              return '/settings';
            }
          }

          if (isScoutManagementRoute) {
            final canViewScouts =
                checker?.hasAnyPermission([
                  PermissionKey.scoutsRead,
                  PermissionKey.scoutsManage,
                ]) ??
                false;
            if (!canViewScouts) {
              return '/settings';
            }
          }
        }

        if (location == '/welcome' ||
            location == '/splash' ||
            location == '/post_sign_in_onboarding') {
          return '/up_next';
        }

        return null;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).trySilentLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final deviceInfo = ref.read(deviceInfoProvider);

    final app = MaterialApp.router(
      routerConfig: router,
      theme: _createTheme(Brightness.light, accentColor),
      darkTheme: _createTheme(Brightness.dark, accentColor),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );

    if (deviceInfo.deviceOS == DeviceOS.macos) {
      return PlatformMenuBar(menus: _buildMacMenus(router), child: app);
    }

    return app;
  }
}

ThemeData _createTheme(Brightness brightness, Color accentColor) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: brightness,
  );

  final baseTheme = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: colorScheme,
    iconTheme: IconThemeData(
      fill: 0.0,
      weight: 600,
      color: colorScheme.onSurface,
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme(
      ThemeData(brightness: brightness, colorScheme: colorScheme).textTheme,
    ),
  );

  return baseTheme.copyWith(
    appBarTheme: baseTheme.appBarTheme.copyWith(
      centerTitle: false,
      titleTextStyle: baseTheme.textTheme.titleLarge!.copyWith(
        fontFamily: 'Xolonium',
        fontSize: 20,
      ),
    ),
    dialogTheme: baseTheme.dialogTheme.copyWith(
      titleTextStyle: baseTheme.textTheme.headlineSmall!.copyWith(
        fontFamily: 'Xolonium',
        fontSize: 20,
      ),
    ),
  );
}

List<PlatformMenu> _buildMacMenus(GoRouter router) {
  return [
    PlatformMenu(
      label: 'Beariscope',
      menus: [
        PlatformMenuItem(
          label: 'About Beariscope',
          onSelected: () => router.push('/settings/about'),
        ),
        PlatformMenuItem(
          label: 'Settings',
          shortcut: const SingleActivator(LogicalKeyboardKey.comma, meta: true),
          onSelected: () => router.push('/settings'),
        ),
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.servicesSubmenu,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.hideOtherApplications,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.showAllApplications,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: 'View',
      menus: [
        PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.toggleFullScreen,
        ),
      ],
    ),
    PlatformMenu(
      label: 'Window',
      menus: [
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.minimizeWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.zoomWindow,
            ),
          ],
        ),
        PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.arrangeWindowsInFront,
        ),
      ],
    ),
  ];
}
