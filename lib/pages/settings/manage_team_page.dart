import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ManageTeamPage extends StatelessWidget {
  const ManageTeamPage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    // final teamProvider = context.watch<TeamProvider>();

    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage [team name here]'),
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
                    // await teamProvider.leaveTeam();
                    // if (context.mounted) {
                    //   context.go('/you');
                    // }
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
            _buildMembersTab(context),
            _buildJoinCodesTab(context),
            _buildRolesTab(context),
            _buildOnboardingTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  Center _buildMembersTab(BuildContext context) {
    // Placeholder for members tab content
    return Center(child: Text('Members in $teamId'));
  }

  Center _buildJoinCodesTab(BuildContext context) {
    // Placeholder for join codes tab content
    return Center(child: Text('Join Codes for $teamId'));
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
