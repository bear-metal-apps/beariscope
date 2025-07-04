import 'package:flutter/material.dart';
import 'package:libkoala/providers/team_provider.dart';
import 'package:provider/provider.dart';

class CreateTeamOnboarding extends StatelessWidget {
  const CreateTeamOnboarding({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Let\'s set up ${teamProvider.teamName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
