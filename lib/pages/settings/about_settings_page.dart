import 'package:beariscope/components/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_icons/simple_icons.dart';
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
                title: const Text('Version'),
                trailing: FutureBuilder<(PackageInfo, String)>(
                  future: Future.wait([
                    PackageInfo.fromPlatform(),
                    rootBundle.loadString('assets/codename.txt'),
                  ]).then(
                    (results) => (
                      results[0] as PackageInfo,
                      (results[1] as String).trim(),
                    ),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading');
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      final (info, codename) = snapshot.data!;
                      final version = info.version;
                      if (codename.isEmpty || codename == 'Unknown') {
                        return Text(version);
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [Text('$version $codename')],
                      );
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Beariscope GitHub'),
                subtitle: const Text('Source code & other downloads'),
                trailing: const Icon(Symbols.open_in_new_rounded),
                onTap:
                    () => _launchUrl(
                      context,
                      'https://github.com/bear-metal-apps/beariscope',
                      'Beariscope GitHub',
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
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Legal',
            children: [
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Symbols.open_in_new_rounded),
                onTap:
                    () => _launchUrl(
                      context,
                      'https://bear-metal-apps.github.io/beariscope/privacy-policy',
                      'Privacy Policy',
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
