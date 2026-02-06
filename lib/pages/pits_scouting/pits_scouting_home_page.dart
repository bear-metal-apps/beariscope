import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final main = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: controller,
          hintText: 'Team name or number',
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search_rounded),

          trailing: [
            IconButton(
              icon: Icon(Icons.filter_list_rounded),
              tooltip: 'Filter & Sort',
              onPressed: () {},
            ),
          ],
        ),
        leading:
            main.isDesktop
                ? SizedBox(width: 40)
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: main.openDrawer,
                ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PitsScoutingTeamCard(teamName: 'Bear Metal', teamNumber: '2046'),
              PitsScoutingTeamCard(teamName: 'SPARX', teamNumber: '1126'),
              PitsScoutingTeamCard(teamName: 'KB Bot', teamNumber: '3311'),
              PitsScoutingTeamCard(teamName: 'ASSIT', teamNumber: '2214'),
              PitsScoutingTeamCard(teamName: 'iDeer', teamNumber: '9427'),
              PitsScoutingTeamCard(
                teamName: 'Team R.O.B.O.T.I.C.S.',
                teamNumber: '107',
              ),
              PitsScoutingTeamCard(
                teamName: 'Sacred Heart Outlanders',
                teamNumber: '10285',
              ),
              PitsScoutingTeamCard(
                teamName: 'The Wolfbotz',
                teamNumber: '4634',
              ),
              PitsScoutingTeamCard(
                teamName: 'The Ninjaneers',
                teamNumber: '1068',
              ),
              PitsScoutingTeamCard(teamName: 'ASCTE', teamNumber: '8605'),
              PitsScoutingTeamCard(
                teamName: 'Mets Robotics',
                teamNumber: '4745',
              ),
              PitsScoutingTeamCard(
                teamName: 'Tiger-OPS Robotics',
                teamNumber: '7214',
              ),
              PitsScoutingTeamCard(teamName: 'ROBOLYNX', teamNumber: '10907'),
              PitsScoutingTeamCard(
                teamName: 'Clarksville Cyber Storm',
                teamNumber: '11037',
              ),
              PitsScoutingTeamCard(
                teamName: 'Power Struck Girls',
                teamNumber: '5965',
              ),
              PitsScoutingTeamCard(
                teamName: 'Team Terminator',
                teamNumber: '5576',
              ),
              PitsScoutingTeamCard(
                teamName: 'Robot Dolphins From Outer Space',
                teamNumber: '5199',
              ),
              PitsScoutingTeamCard(
                teamName: 'Cyber Cougars',
                teamNumber: '6089',
              ),
              PitsScoutingTeamCard(
                teamName: 'Manic Mechanics',
                teamNumber: '1851',
              ),
              PitsScoutingTeamCard(teamName: 'Wildcogs', teamNumber: '3123'),
              PitsScoutingTeamCard(teamName: 'Weber Fever', teamNumber: '1724'),
              PitsScoutingTeamCard(teamName: '--', teamNumber: '1364'),
              PitsScoutingTeamCard(
                teamName: 'The Marist Manta Rays',
                teamNumber: '6772',
              ),
              PitsScoutingTeamCard(teamName: 'SpicyBots', teamNumber: '8138'),
              PitsScoutingTeamCard(teamName: 'Panteras', teamNumber: '2283'),
              PitsScoutingTeamCard(
                teamName: 'The Ducksons',
                teamNumber: '10508',
              ),
              PitsScoutingTeamCard(teamName: 'Rambots', teamNumber: '2204'),
              PitsScoutingTeamCard(
                teamName: 'Greased Lighting',
                teamNumber: '4379',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PitsScoutingTeamCard extends StatefulWidget {
  final String teamName;
  final String teamNumber;
  final double? height;

  const PitsScoutingTeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
    this.height,
  });

  @override
  State<PitsScoutingTeamCard> createState() => _PitsScoutingTeamCardState();
}

class _PitsScoutingTeamCardState extends State<PitsScoutingTeamCard> {
  bool scouted = false;

  @override
  Widget build(BuildContext context) {
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
                      ),
                ),
              );

              if (result != null && result == true) {
                setState(() {
                  scouted = result;
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
                        widget.teamNumber,
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

class _ScoutingPage extends StatefulWidget {
  final String teamName;
  final String teamNumber;

  const _ScoutingPage({required this.teamName, required this.teamNumber});

  @override
  State<_ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends State<_ScoutingPage> {
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
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
