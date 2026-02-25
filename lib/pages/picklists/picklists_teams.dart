import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/picklists/picklist_model.dart';
import 'package:beariscope/pages/settings/appearance_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hive_ce_flutter/adapters.dart';

class PicklistsTeamsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? picklist;

  const PicklistsTeamsPage({super.key, this.picklist});

  @override
  ConsumerState<PicklistsTeamsPage> createState() => _PicklistsTeamsPageState();
}

class _PicklistsTeamsPageState extends ConsumerState<PicklistsTeamsPage> {
  late List<Map<String, dynamic>> teams;
  Map<String, dynamic>? picklistLocal;

  @override
  void initState() {
    super.initState();
    picklistLocal =
        widget.picklist != null ? Map<String, dynamic>.from(widget.picklist!) : null;
    teams = (picklistLocal?['teams'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
  }

  String _teamNumber(Map<String, dynamic> team) {
    final teamNumber = team['team_number']?.toString();
    if (teamNumber != null && teamNumber.isNotEmpty) return teamNumber;

    final key = (team['team_key'] ?? team['key'] ?? '').toString();
    final match = RegExp(r"(\d+)").firstMatch(key);
    if (match != null) return match.group(0)!;

    return '';
  }

  String _teamName(Map<String, dynamic> team) {
    return (team['nickname'] ?? team['name'] ?? team['team_name'] ?? '')
        .toString();
  }

  Future<void> _savePicklistOrder() async {
    final id = picklistLocal?['id']?.toString();
    final password = picklistLocal?['password']?.toString();
    if (id == null || id.isEmpty || password == null || password.isEmpty) return;

    picklistLocal!['teams'] = teams;

    // create updated picklist object
    final updatedPicklist = Picklist.fromMap(picklistLocal!);

    // find old picklist by password and replace it
    ref.read(picklistProvider.notifier).updatePicklist(
      Picklist.fromMap(picklistLocal!),
      updatedPicklist,
    );

    // save to hive
    final box = await Hive.openBox('picklists');
    await box.put(id, picklistLocal);
  }

  Future<void> _deletePicklist() async {
    final id = picklistLocal?['id']?.toString();
    if (id == null || id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Picklist?'),
        content: const Text(
            'Are you sure you want to delete this entire picklist? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // delete from Hive
        final box = await Hive.openBox('picklists');
        await box.delete(id);
        await box.close();

        // remove from notifier
        ref.read(picklistProvider.notifier).removePicklist(Picklist.fromMap(picklistLocal!));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Picklist deleted')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting picklist: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    final accentColor = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(picklistLocal?['name'] ?? 'Picklist'),
        leading: controller.isDesktop
            ? null
            : IconButton(
                icon: const Icon(Symbols.menu_rounded),
                onPressed: controller.openDrawer,
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePicklist,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                try {
                  await _savePicklistOrder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Picklist saved')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving: $e')),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: teams.isEmpty
          ? const Center(child: Text('No teams'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: teams.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = teams.removeAt(oldIndex);
                  teams.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final team = teams[index];
                final number = _teamNumber(team);
                final name = _teamName(team);
                final teamKey =
                    (team['team_key'] ?? team['key'] ?? '').toString();

                return Card(
                  key: ValueKey(teamKey.isNotEmpty ? teamKey : index),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        number.isNotEmpty ? number : '?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(name.isNotEmpty ? name : teamKey),
                    subtitle: Text(teamKey),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: accentColor),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Team?'),
                            content: const Text(
                                'Are you sure you want to remove this team from the picklist?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            teams.removeAt(index);
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
