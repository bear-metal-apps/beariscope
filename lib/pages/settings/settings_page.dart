import 'package:beariscope/components/settings_group.dart';
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
                  await ref.read(authProvider).logout();
                }
              },
              icon: const Icon(Symbols.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 16),

          SettingsGroup(
            title: 'General',
            children: [
              ListTile(
                leading: const Icon(Symbols.person_rounded),
                title: const Text('Account'),
                subtitle: const Text('Email, Password'),
                onTap: () => context.push('/settings/account'),
              ),
              ListTile(
                leading: const Icon(Symbols.person_add),
                title: const Text('User Selection'),
                subtitle: const Text('Swap Users, Add Users'),
                onTap: () => context.push('/settings/user_selection'),
              ),
              ListTile(
                leading: const Icon(Symbols.notifications_rounded),
                title: const Text('Notifications'),
                subtitle: const Text('Queuing, Schedule Release'),
                onTap: () => context.push('/settings/notifications'),
              ),
              ListTile(
                leading: const Icon(Symbols.palette_rounded),
                title: const Text('Appearance'),
                subtitle: const Text('Theme, UI Options'),
                onTap: () => context.push('/settings/appearance'),
              ),
              ListTile(
                leading: const Icon(Symbols.group),
                title: const Text('Members'),
                subtitle: const Text('Roles'),
                onTap: () => context.push('/settings/roles'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          SettingsGroup(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Symbols.info_rounded),
                title: const Text('About'),
                subtitle: const Text('Version, Acknowledgements'),
                onTap: () => context.push('/settings/about'),
              ),
              ListTile(
                leading: const Icon(Symbols.license_rounded),
                title: const Text('Licenses'),
                subtitle: const Text('Licenses, Open Source'),
                onTap: () => context.push('/settings/licenses'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
