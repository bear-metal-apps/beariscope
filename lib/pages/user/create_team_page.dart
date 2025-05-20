import 'package:flutter/material.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamNumberController = TextEditingController();

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
                constraints: BoxConstraints(maxWidth: 300),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamNumberController,
              decoration: const InputDecoration(
                labelText: 'Team Number',
                border: OutlineInputBorder(),
                constraints: BoxConstraints(maxWidth: 300),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final String teamName = _teamNameController.text;
                final String teamNumber = _teamNumberController.text;
              },
              child: const Text('Register Team'),
            ),
          ],
        ),
      ),
    );
  }
}
