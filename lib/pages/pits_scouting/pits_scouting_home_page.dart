import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_assets.dart';

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchTermTEC = TextEditingController();
    final main = MainViewController.of(context);
    List<Widget> teams = [
      PitsScoutingTeamCard(
        teamName: 'Bear Metal',
        teamNumber: 2046,
        cardID: 1,
      ),
      PitsScoutingTeamCard(
        teamName: 'SPARX',
        teamNumber: 1126,
        cardID: 2,
      ),
      PitsScoutingTeamCard(
        teamName: 'KB Bot',
        teamNumber: 3311,
        cardID: 3,
      ),
      PitsScoutingTeamCard(
        teamName: 'ASSIT',
        teamNumber: 2214,
        cardID: 4,
      ),
      PitsScoutingTeamCard(
        teamName: 'iDeer',
        teamNumber: 9427,
        cardID: 5,
      ),
      PitsScoutingTeamCard(
        teamName: 'Team R.O.B.O.T.I.C.S.',
        teamNumber: 107,
        cardID: 6,
      ),
      PitsScoutingTeamCard(
        teamName: 'Sacred Heart Outlanders',
        teamNumber: 10285,
        cardID: 7,
      ),
      PitsScoutingTeamCard(
        teamName: 'The Wolfbotz',
        teamNumber: 4634,
        cardID: 8,
      ),
      PitsScoutingTeamCard(
        teamName: 'The Ninjaneers',
        teamNumber: 1068,
        cardID: 9,
      ),
      PitsScoutingTeamCard(
        teamName: 'ASCTE',
        teamNumber: 8605,
        cardID: 10,
      ),
      PitsScoutingTeamCard(
        teamName: 'Mets Robotics',
        teamNumber: 4745,
        cardID: 11,
      ),
      PitsScoutingTeamCard(
        teamName: 'Tiger-OPS Robotics',
        teamNumber: 7214,
        cardID: 12,
      ),
      PitsScoutingTeamCard(
        teamName: 'ROBOLYNX',
        teamNumber: 10907,
        cardID: 13,
      ),
      PitsScoutingTeamCard(
        teamName: 'Clarksville Cyber Storm',
        teamNumber: 11037,
        cardID: 14,
      ),
      PitsScoutingTeamCard(
        teamName: 'Power Struck Girls',
        teamNumber: 5965,
        cardID: 15,
      ),
      PitsScoutingTeamCard(
        teamName: 'Team Terminator',
        teamNumber: 5576,
        cardID: 16,
      ),
      PitsScoutingTeamCard(
        teamName: 'Robot Dolphins From Outer Space',
        teamNumber: 5199,
        cardID: 17,
      ),
      PitsScoutingTeamCard(
        teamName: 'Cyber Cougars',
        teamNumber: 6089,
        cardID: 18,
      ),
      PitsScoutingTeamCard(
        teamName: 'Manic Mechanics',
        teamNumber: 1851,
        cardID: 19,
      ),
      PitsScoutingTeamCard(
        teamName: 'Wildcogs',
        teamNumber: 3123,
        cardID: 20,
      ),
      PitsScoutingTeamCard(
        teamName: 'Weber Fever',
        teamNumber: 1724,
        cardID: 21,
      ),
      PitsScoutingTeamCard(
        teamName: '--',
        teamNumber: 1364,
        cardID: 22,
      ),
      PitsScoutingTeamCard(
        teamName: 'The Marist Manta Rays',
        teamNumber: 6772,
        cardID: 23,
      ),
      PitsScoutingTeamCard(
        teamName: 'SpicyBots',
        teamNumber: 8138,
        cardID: 24,
      ),
      PitsScoutingTeamCard(
        teamName: 'Panteras',
        teamNumber: 2283,
        cardID: 25,
      ),
      PitsScoutingTeamCard(
        teamName: 'The Ducksons',
        teamNumber: 10508,
        cardID: 26,
      ),
      PitsScoutingTeamCard(
        teamName: 'Rambots',
        teamNumber: 2204,
        cardID: 27,
      ),
      PitsScoutingTeamCard(
        teamName: 'Greased Lighting',
        teamNumber: 4379,
        cardID: 28,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: searchTermTEC,
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
            children: teams
          ),
        ),
      ),
    );
  }
}
