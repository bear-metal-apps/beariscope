import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_cards_provider.dart';

class PitsScoutingTeamCard extends ConsumerStatefulWidget {
  final String teamName;
  final int teamNumber;
  final bool? scouted;
  final double? height;
  final int cardID;

  const PitsScoutingTeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
    this.scouted,
    this.height,
    required this.cardID,
  });

  @override
  ConsumerState<PitsScoutingTeamCard> createState() =>
      _PitsScoutingTeamCardState();
}

class _PitsScoutingTeamCardState extends ConsumerState<PitsScoutingTeamCard> {
  @override
  Widget build(BuildContext context) {
    final scouted = ref.watch(scoutedNotifierProvider)[widget.cardID];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => _ScoutingPage(
                        teamNumber: widget.teamNumber,
                        teamName: widget.teamName,
                        scouted: scouted,
                      ),
                ),
              );

              if (result != null && result == true) {
                setState(() {
                  ref
                      .read(scoutedNotifierProvider.notifier)
                      .replaceValue(widget.cardID);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: widget.height ?? 93,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.teamName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.teamNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox(height: 89)),
                  scouted == false
                      ? Text(
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        'Not Scouted',
                      )
                      : Text(
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        'Scouted',
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoutingPage extends ConsumerStatefulWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;

  const _ScoutingPage({
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
  });

  @override
  ConsumerState<_ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends ConsumerState<_ScoutingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scouting: ${widget.teamName} ${widget.teamNumber}'),
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
