import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterTeamPage extends StatefulWidget {
  const RegisterTeamPage({super.key});

  @override
  State<RegisterTeamPage> createState() => _RegisterTeamPageState();
}

class _RegisterTeamPageState extends State<RegisterTeamPage> {
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
      appBar: AppBar(title: const Text('Register Team')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamNumberController,
              decoration: const InputDecoration(
                labelText: 'Team Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                // Handle team registration logic here
                // For example, you can send the data to your backend or save it locally
                final String teamName = _teamNameController.text;
                final String teamNumber = _teamNumberController.text;

                // Simulate successful registration
                context.go('/welcome/signup/user_details');
              },
              child: const Text('Register Team'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.go('/welcome/signup');
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
