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
      appBar: AppBar(title: const Text('Members')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TeamMemberCard(name: 'Person 1'),
          SizedBox(height: 12),
          TeamMemberCard(name: 'Person 2'),
          SizedBox(height: 12),
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
  String? _selectedRole;
  final List<String> roles = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.account_circle,
              size: 52,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
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
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
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
                        },
                        child: const Text('Assign Roles'),
                      ),

                    ],
                  ),
                  const SizedBox(height: 12),
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

