import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/team_provider.dart';
import 'package:provider/provider.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _teamNameController.addListener(() {
      setState(() {});
    });
    _teamNumberController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamNumberController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    final String teamName = _teamNameController.text;
    final int teamNumber = int.parse(_teamNumberController.text);

    setState(() {
      _isLoading = true;
    });

    final teamProvider = context.read<TeamProvider>();

    teamProvider
        .createTeam(teamName: teamName, teamNumber: teamNumber)
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.toString()}')),
            );
          });
        });
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
              decoration: InputDecoration(
                labelText: 'Team Name',
                border: const OutlineInputBorder(),
                constraints: const BoxConstraints(maxWidth: 300),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamNumberController,
              decoration: InputDecoration(
                labelText: 'Team Number',
                border: const OutlineInputBorder(),
                constraints: const BoxConstraints(maxWidth: 300),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  !_isLoading &&
                          _teamNameController.text.isNotEmpty &&
                          _teamNumberController.text.isNotEmpty
                      ? () {
                        _createTeam();
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
                      : const Text('Create Team'),
            ),
          ],
        ),
      ),
    );
  }
}
