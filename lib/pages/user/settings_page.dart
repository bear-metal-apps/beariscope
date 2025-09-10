import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/providers/user_info_provider.dart';
import 'package:libkoala/ui/widgets/profile_picture.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final userInfo = ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          Center(child: ProfilePicture(size: 72)),
          const SizedBox(height: 12),
          Text(
            userInfo.value?.name ?? 'No Name',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            userInfo.value?.email ?? 'No Email',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              onPressed: () async {
                final bool confirmed =
                    await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                    ) ??
                    false;
                if (confirmed && context.mounted) {
                  await auth.logout();
                }
              },
              icon: const Icon(Symbols.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 32),

          // General
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'General',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Symbols.person_rounded),
                      title: const Text('Account'),
                      subtitle: const Text('Profile, email, password'),
                      onTap: () => context.push('/settings/account'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Symbols.notifications_rounded),
                      title: const Text('Notifications'),
                      subtitle: const Text('Push, email, in-app'),
                      onTap: () => context.push('/settings/notifications'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Symbols.palette_rounded),
                      title: const Text('Appearance'),
                      subtitle: const Text('Theme, UI Options'),
                      onTap: () => context.push('/settings/appearance'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'About',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Symbols.info_rounded),
                      title: const Text('About'),
                      subtitle: const Text('Version, Acknowledgements'),
                      onTap: () => context.push('/settings/about'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Symbols.license_rounded),
                      title: const Text('Licenses'),
                      subtitle: const Text('Licenses, Open Source'),
                      onTap: () => context.push('/settings/licenses'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
