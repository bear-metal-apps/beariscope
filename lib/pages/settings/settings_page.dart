import 'package:beariscope/components/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/libkoala.dart';
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
