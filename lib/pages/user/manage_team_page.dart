import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/team_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ManageTeamPage extends StatelessWidget {
  const ManageTeamPage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();

    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage ${teamProvider.teamName}'),
          actionsPadding: const EdgeInsets.only(right: 16),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Symbols.more_vert_rounded),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'leave',
                    child: const Text('Leave Team'),
                  ),
                ];
              },
              onSelected: (String value) async {
                if (value == 'leave') {
                  final bool confirmed =
                      await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Leave'),
                              content: const Text(
                                'Are you sure you want to leave this team?',
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
                                  child: const Text('Leave'),
                                ),
                              ],
                            ),
                      ) ??
                      false;
                  if (confirmed && context.mounted) {
                    await teamProvider.leaveTeam();
                    if (context.mounted) {
                      context.go('/you');
                    }
                  }
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Join Codes'),
              Tab(text: 'Roles'),
              Tab(text: 'Onboarding'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMembersTab(context, teamProvider),
            _buildJoinCodesTab(context, teamProvider),
            _buildRolesTab(context),
            _buildOnboardingTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  Center _buildMembersTab(BuildContext context, TeamProvider teamProvider) {
    // Placeholder for members tab content
    return Center(child: Text('Members in $teamId'));
  }

  Center _buildJoinCodesTab(BuildContext context, TeamProvider teamProvider) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () async {
          String joinCode = await teamProvider.createJoinCode() ?? '';

          if (!context.mounted) return;
          if (joinCode.isNotEmpty) {
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Join Code'),
                    content: Text('Join code: $joinCode'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: joinCode));
                        },
                        child: const Text('Copy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        },
        icon: const Icon(Symbols.qr_code_2_rounded),
        label: const Text('Create Join Code'),
      ),
    );
  }

  Center _buildRolesTab(BuildContext context) {
    // Placeholder for roles tab content
    return Center(child: Text('Roles in $teamId'));
  }

  Center _buildOnboardingTab(BuildContext context) {
    // Placeholder for onboarding tab content
    return Center(child: Text('Onboarding for $teamId'));
  }

  Center _buildSettingsTab(BuildContext context) {
    // Placeholder for settings tab content
    return Center(child: Text('Settings for $teamId'));
  }
}
