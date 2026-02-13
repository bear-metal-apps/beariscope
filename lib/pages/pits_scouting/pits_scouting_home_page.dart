import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_assets.dart';
import 'package:beariscope/pages/team_lookup/team_lookup_page.dart';

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
  late List<Team> teams;

  List<Team> filteredTeams = [];
  List<PitsScoutingTeamCard> teamCards = [];

  Filter pitsFilter = Filter.allEvents;

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

  Widget constructList(
    AsyncValue<List<dynamic>> allTeams,
    AsyncValue<List<dynamic>> currentEventTeams,
    GetListDataProvider allTeamsProvider,
    GetListDataProvider currentEventTeamsProvider,
  ) {
    if (pitsFilter == Filter.currentEventsOnly) {
      return currentEventTeams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(currentEventTeamsProvider),
                child: const Text('Retry'),
              ),
            ),
        data: (data) {
          return Center();
        },
      );
    } else {
      return allTeams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(allTeamsProvider),
                child: const Text('Retry'),
              ),
            ),
        data: (data) {
          return Center(
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
          );
        },
      );
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
    final allTeamsProvider = getListDataProvider(endpoint: '/teams');
    final currentEventTeamsProvider = getListDataProvider(
      endpoint: '/teams?event=${ref.read(currentEventProvider)}',
    );
    final allTeamsAsync = ref.watch(allTeamsProvider);
    final currentEventTeamsAsync = ref.watch(currentEventTeamsProvider);

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
            PopupMenuButton(
              icon: Icon(Icons.filter_list_rounded),
              tooltip: 'Filter & Sort',
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: Filter.allEvents,
                      child: Text('All Events'),
                    ),
                    PopupMenuItem(
                      value: Filter.currentEventsOnly,
                      child: Text('Current Event Only'),
                    ),
                  ],
              onSelected: (Filter newValue) {
                setState(() {
                  pitsFilter = newValue;
                });
              },
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
      body: constructList(
        allTeamsAsync,
        currentEventTeamsAsync,
        allTeamsProvider,
        currentEventTeamsProvider,
      ),
    );
  }
}
