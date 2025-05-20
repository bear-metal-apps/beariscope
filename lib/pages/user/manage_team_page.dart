import 'package:beariscope/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ManageTeamPage extends StatelessWidget {
  const ManageTeamPage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Manage ${teamProvider.teamName}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Managing teams is coming soon!'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final bool confirmed =
                    await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Leave Team'),
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
              },
              icon: const Icon(Symbols.group_remove_rounded),
              label: const Text('Leave Team'),
            ),
          ],
        ),
      ),
    );
  }
}
