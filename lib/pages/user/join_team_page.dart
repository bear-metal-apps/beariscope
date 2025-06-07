import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/team_provider.dart';
import 'package:provider/provider.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final TextEditingController _joinCodeController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _joinCodeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Join Team')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _joinCodeController,
              decoration: const InputDecoration(
                labelText: 'Join Code',
                border: OutlineInputBorder(),
                constraints: BoxConstraints(maxWidth: 300),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  !_isLoading && _joinCodeController.text.isNotEmpty
                      ? () {
                        setState(() {
                          _isLoading = true;
                        });

                        final String joinCode = _joinCodeController.text;

                        teamProvider.useJoinCode(joinCode).then((_) {
                          // Wait a moment because magic sauce
                          Future.delayed(const Duration(milliseconds: 500), () {
                            teamProvider
                                .refreshCurrentTeam()
                                .then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (!mounted) return;
                                  context.go('/you');
                                })
                                .catchError((error) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error: ${error.toString()}',
                                      ),
                                    ),
                                  );
                                });
                          });
                        });
                      }
                      : null,
              child:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                      : const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
