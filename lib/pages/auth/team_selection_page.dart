import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Team')),
      body: Center(
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () {},
              label: const Text('Scan Team Code'),
              icon: const Icon(Symbols.qr_code_scanner_rounded),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              label: const Text('Enter Team Code'),
              icon: const Icon(Symbols.text_fields_rounded),
            ),
            OutlinedButton.icon(
              onPressed: () {
                context.go('/welcome/signup/register_team');
              },
              label: const Text('Register your team'),
              icon: const Icon(Symbols.add_circle_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
