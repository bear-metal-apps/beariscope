import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterTeamPage extends StatefulWidget {
  const RegisterTeamPage({super.key});

  @override
  State<RegisterTeamPage> createState() => _RegisterTeamPageState();
}

class _RegisterTeamPageState extends State<RegisterTeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamEmailController = TextEditingController();
  final TextEditingController _teamPasswordController = TextEditingController();
  final TextEditingController _teamConfirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamEmailController.dispose();
    _teamPasswordController.dispose();
    _teamConfirmPasswordController.dispose();
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
            const Text(
              'Sorry, external team registration is not available yet.',
            ),
            const SizedBox(height: 20),
            FilledButton(
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
