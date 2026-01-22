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
                              bool driveTeam = false;
                              bool scouting = false;
                              bool admin = false;

                              return AlertDialog(
                                title: const Text('Assign Roles'),
                                content: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CheckboxListTile(
                                          title: const Text('Drive Team'),
                                          value: driveTeam,
                                          onChanged: (val) =>
                                              setState(() => driveTeam = val!),
                                        ),
                                        CheckboxListTile(
                                          title: const Text('Scouting'),
                                          value: scouting,
                                          onChanged: (val) =>
                                              setState(() => scouting = val!),
                                        ),
                                        CheckboxListTile(
                                          title: const Text('Admin'),
                                          value: admin,
                                          onChanged: (val) =>
                                              setState(() => admin = val!),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Assign Roles'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

