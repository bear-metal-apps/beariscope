import 'package:beariscope/pages/picklists/picklist_model.dart';
import 'package:beariscope/pages/picklists/picklist_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PicklistsCreatePage extends ConsumerStatefulWidget {
  const PicklistsCreatePage({super.key});

  @override
  ConsumerState<PicklistsCreatePage> createState() {
    return PicklistsCreatePageState();
  }
}

class PicklistsCreatePageState extends ConsumerState<PicklistsCreatePage> {
  final TextEditingController picklistNameTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  String? selectedEventKey;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(picklistEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Picklist')),
      body: Center(
        child: eventsAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
          data: (events) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter picklist name',
                    ),
                    controller: picklistNameTEC,
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter password',

                    ),
                    controller: passwordTEC,
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 12),
                DropdownMenu<String>(
                  width: 250,
                  enableFilter: true,
                  hintText: 'Select an event',
                  dropdownMenuEntries: events.map((event) {
                    final eventKey = (event['key'] ?? '').toString();
                    final eventName = (event['name'] ?? 'Unknown').toString();
                    return DropdownMenuEntry(
                      value: eventKey,
                      label: eventName,
                    );
                  }).toList(),
                  onSelected: (String? eventKey) {
                    setState(() {
                      selectedEventKey = eventKey;
                    });
                  },
                ),
                SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (picklistNameTEC.text.isEmpty ||
                        passwordTEC.text.isEmpty ||
                        selectedEventKey == null ||
                        selectedEventKey!.isEmpty) {
                      return;
                    }

                    try {
                      final teams = await ref.read(
                          teamsForEventProvider(selectedEventKey!).future);

                      final eventName = events
                          .firstWhere(
                              (e) =>
                                  (e['key'] ?? '').toString() ==
                                  selectedEventKey,
                              orElse: () => {})['name']
                          ?.toString() ??
                          '';

                      final picklistId =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      final picklist = Picklist(
                        id: picklistId,
                        name: picklistNameTEC.text,
                        password: passwordTEC.text,
                        eventKey: selectedEventKey!,
                        eventName: eventName,
                        teams: teams,
                        createdAt: DateTime.now().toIso8601String(),
                      );

                      context.push('/picklists/view', extra: picklist.toMap());
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to create picklist: $e')));
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    picklistNameTEC.dispose();
    passwordTEC.dispose();
    super.dispose();
  }
}
