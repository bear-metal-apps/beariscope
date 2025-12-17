import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PicklistsCreatePage extends StatefulWidget {
  const PicklistsCreatePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return PicklistsCreatePageState();
  }
}

class PicklistsCreatePageState extends State<PicklistsCreatePage> {
  final TextEditingController picklistNameTEC = TextEditingController();
  String competitionNameDropdownValue = 'Set competition';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Picklist'),
      ),
      body: Center(
        child: Column(
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
            DropdownMenu(
              width: 250,
              enableFilter: true,
              hintText: 'Select a competition',
              dropdownMenuEntries: <DropdownMenuEntry<String>>[
                DropdownMenuEntry(
                  value: 'Competition 1',
                  label: 'Competition 1',
                ),
                DropdownMenuEntry(
                  value: 'Competition 2',
                  label: 'Competition 2',
                ),
                DropdownMenuEntry(
                  value: 'Competition 3',
                  label: 'Competition 3',
                ),
                DropdownMenuEntry(
                  value: 'Competition 4',
                  label: 'Competition 4',
                ),
                DropdownMenuEntry(
                  value: 'Competition 5',
                  label: 'Competition 5',
                ),
              ],
              onSelected: (String? competition) {
                setState(() {
                  competitionNameDropdownValue = competition!;
                });
              },
            ),
            SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (picklistNameTEC.text != '' &&
                    competitionNameDropdownValue != '') {
                  // createPicklist();
                  context.push('/picklists');
                }
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
