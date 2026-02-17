import 'package:flutter/material.dart';
import 'package:beariscope/components/beariscope_card.dart';

class PitsScoutingTeamCard extends StatelessWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;
  final ValueChanged<bool> onScoutedChanged;

  const PitsScoutingTeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
    required this.onScoutedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BeariscopeCard(
      title: teamName,
      subtitle: '$teamNumber',
      trailing: Text(
        scouted ? 'Scouted' : 'Not Scouted',
        style: TextStyle(
          color: scouted ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => _ScoutingPage(
                  teamNumber: teamNumber,
                  teamName: teamName,
                  scouted: scouted,
                ),
          ),
        );

        if (result != null && result == true) {
          onScoutedChanged(true);
        }
      },
    );
  }
}

class _ScoutingPage extends StatefulWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;

  const _ScoutingPage({
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
  });

  @override
  State<_ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends State<_ScoutingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scouting ${widget.teamNumber}: ${widget.teamName}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(widget.scouted == false ? 'Submit' : 'Edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
