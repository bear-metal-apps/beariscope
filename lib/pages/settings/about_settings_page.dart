import 'package:beariscope/components/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  Future<void> _launchUrl(
    BuildContext context,
    String url,
    String label,
  ) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $label')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsGroup(
            title: 'App',
            children: [
              ListTile(
                leading: const Icon(Symbols.update_rounded),
                title: const Text('Version'),
                trailing: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading');
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      return Text(snapshot.data?.version ?? 'Unknown');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Data Sources',
            children: [
              ListTile(
                title: const Text('The Blue Alliance'),
                subtitle: const Text('Match schedule & team data'),
                trailing: const Icon(Symbols.open_in_new_rounded),
                onTap:
                    () => _launchUrl(
                      context,
                      'https://www.thebluealliance.com',
                      'The Blue Alliance',
                    ),
              ),
              ListTile(
                title: const Text('FRC Nexus'),
                subtitle: const Text('Event pit & queue information'),
                trailing: const Icon(Symbols.open_in_new_rounded),
                onTap:
                    () => _launchUrl(context, 'https://frc.nexus', 'FRC Nexus'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
