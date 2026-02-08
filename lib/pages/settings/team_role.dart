import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamRolesPage extends ConsumerStatefulWidget {
  const TeamRolesPage({super.key});

  @override
  ConsumerState<TeamRolesPage> createState() => _TeamRolesPageState();
}

class _TeamRolesPageState extends ConsumerState<TeamRolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beariscope Users')),
      body: BeariscopeCardList(
        children: const [
          TeamMemberCard(name: 'Person 1'),
          TeamMemberCard(name: 'Person 2'),
          TeamMemberCard(name: 'Person 3'),
        ],
      ),
    );
  }
}

class TeamMemberCard extends StatefulWidget {
  final String name;

  const TeamMemberCard({super.key, required this.name});

  @override
  State<TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<TeamMemberCard> {
  final List<String> roles = [];

  void _showRoleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempRoles = List.from(roles);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Assign Roles'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Role 1'),
                    value: tempRoles.contains('Role 1'),
                    onChanged: (isChecked) {
                      setDialogState(() {
                        if (isChecked == true) {
                          tempRoles.add('Role 1');
                        } else {
                          tempRoles.remove('Role 1');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Role 2'),
                    value: tempRoles.contains('Role 2'),
                    onChanged: (isChecked) {
                      setDialogState(() {
                        if (isChecked == true) {
                          tempRoles.add('Role 2');
                        } else {
                          tempRoles.remove('Role 2');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Admin'),
                    value: tempRoles.contains('Admin'),
                    onChanged: (isChecked) {
                      setDialogState(() {
                        if (isChecked == true) {
                          tempRoles.add('Admin');
                        } else {
                          tempRoles.remove('Admin');
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      roles
                        ..clear()
                        ..addAll(tempRoles);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.account_circle,
              size: 52,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton(
                        onPressed: _showRoleDialog,
                        child: const Text('Assign Roles'),
                      ),
                    ],
                  ),
                  if (roles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: roles.map((role) {
                        return Chip(
                          label: Text(role),
                          onDeleted: () {
                            setState(() {
                              roles.remove(role);
                            });
                          },
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}