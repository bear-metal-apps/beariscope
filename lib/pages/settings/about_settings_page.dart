import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: BeariscopeCardList(
        children: [
          BeariscopeCard(
            title: 'Version',
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading');
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  final version = snapshot.data?.version ?? 'Unknown';
                  return Text(version);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
