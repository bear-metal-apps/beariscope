import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_assets.dart';

class Team {
  String teamName;
  int teamNumber;

  Team(this.teamName, this.teamNumber);
}

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
  final List<Team> teams = [
    Team('Bear Metal', 2046),
    Team('SPARX', 1126),
    Team('KB Bot', 3311),
    Team('ASSIT', 2214),
    Team('iDeer', 9427),
    Team('Team R.O.B.O.T.I.C.S.', 107),
    Team('Scared Heart Outlanders', 10285),
    Team('The Wolfbotz', 4634),
    Team('The Ninjaneers', 1068),
    Team('ASCTE', 8605),
    Team('Mets Robotics', 4745),
    Team('Tiger-OPS Robotics', 7214),
    Team('ROBOLYNX', 10907),
    Team('Clarksville Cyber Storm', 11037),
    Team('Power Struck Girls', 5965),
    Team('Team Terminator', 5576),
    Team('Robot Dolphins From Outer Space', 5199),
    Team('Cyber Courgars', 6089),
    Team('Manic Mechanics', 1851),
    Team('Wildcogs', 3123),
    Team('Weber Fever', 1724),
    Team('--', 1364),
    Team('The Marist Manta Rays', 6772),
    Team('SpicyBots', 8138),
    Team('Panteras', 2283),
    Team('The Ducksons', 10508),
    Team('Rambots', 2204),
    Team('Greased Lightning', 4379),
  ];

  List<Team> filteredTeams = [];
  List<PitsScoutingTeamCard> teamCards = [];

  bool isInt(String input) => int.tryParse(input) != null;

  List<Team> searchTeams(List<Team> list) {
    return list;
  }

  List<Team> byName(String name, List<Team> list) {
    final modifiedName = name.toLowerCase();
    return list
        .where((t) => t.teamName.toLowerCase().contains(modifiedName))
        .toList();
  }

  List<Team> byNumber(int number, List<Team> list) {
    return list
        .where((t) => t.teamNumber.toString().contains(number.toString()))
        .toList();
  }

  void filter(String query, List<Team> fullList) {
    if (query.isEmpty) {
      filteredTeams = fullList;
      return;
    }

    if (isInt(query)) {
      filteredTeams = byNumber(int.parse(query), fullList);
    } else {
      filteredTeams = byName(query, fullList);
    }
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < teams.length; i++) {
      teamCards.add(
        PitsScoutingTeamCard(
          teamName: teams[i].teamName,
          teamNumber: teams[i].teamNumber,
          cardID: i,
        ),
      );
    }

    filteredTeams = teams;
  }

  final TextEditingController searchTermTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);

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
          onChanged: (value) {
            setState(() => filter(value, teams));
          },
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
            children:
                filteredTeams.map((team) {
                  return PitsScoutingTeamCard(
                    teamName: team.teamName,
                    teamNumber: team.teamNumber,
                    cardID: teams.indexOf(team),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
