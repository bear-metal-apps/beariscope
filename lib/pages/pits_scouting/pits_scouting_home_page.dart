import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_assets.dart';
import 'package:beariscope/pages/team_lookup/team_lookup_page.dart';

class Team {
  final String teamName;
  final int teamNumber;

  Team(this.teamName, this.teamNumber);
}

final allTeamsProvider = getListDataProvider(endpoint: '/teams');

final currentEventTeamsProvider = Provider((ref) {
  return getListDataProvider(endpoint: '/teams?event=${ref.watch(currentEventProvider)}');
});

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<PitsScoutingHomePage> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
  List<Team> teams = [];
  List<Team> filteredTeams = [];

  Filter pitsFilter = Filter.allEvents;

  bool isInt(String input) => int.tryParse(input) != null;

  void filter(String query) {
    if (query.isEmpty) {
      filteredTeams = teams;
      return;
    }

    if (isInt(query)) {
      final number = int.parse(query);
      filteredTeams = teams
          .where((t) => t.teamNumber.toString().contains(number.toString()))
          .toList();
    } else {
      final q = query.toLowerCase();
      filteredTeams = teams
          .where((t) => t.teamName.toLowerCase().contains(q))
          .toList();
    }
  }

  // ---------------------------------------------
  // FIX 2: Typed model → no more Map<String, String>
  // ---------------------------------------------
  List<Team> mapTeams(List<dynamic> data) {
    return data.map((item) {
      return Team(
        item["nickname"] as String,
        int.parse(item["teamNumber"] as String),
      );
    }).toList()
      ..sort((a, b) => a.teamNumber.compareTo(b.teamNumber));
  }
  Widget buildTeamList() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: filteredTeams
              .map((team) => PitsScoutingTeamCard(
            teamName: team.teamName,
            teamNumber: team.teamNumber,
            cardID: team.teamNumber,
          ))
              .toList(),
        ),
      ),
    );
  }

  final TextEditingController searchTermTEC = TextEditingController();

  @override
  void dispose() {
    searchTermTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);

    final currentEventTeamsProviderGet = ref.watch(currentEventTeamsProvider);

    final allTeamsAsync = ref.watch(allTeamsProvider);
    final currentEventTeamsAsync = ref.watch(currentEventTeamsProviderGet);

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
          leading: const Icon(Symbols.search_rounded),
          trailing: [
            PopupMenuButton(
              icon: const Icon(Symbols.filter_list_rounded),
              tooltip: 'Filter & Sort',
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: Filter.allEvents,
                  child: Text('All Events'),
                ),
                const PopupMenuItem(
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
            setState(() {
              filter(value);
            });
          },
        ),
        leading: main.isDesktop
            ? const SizedBox(width: 40)
            : IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: main.openDrawer,
        ),
      ),
      body: pitsFilter == Filter.currentEventsOnly
          ? currentEventTeamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: FilledButton(
            onPressed: () =>
                ref.invalidate(currentEventTeamsProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (data) {
          teams = mapTeams(data);
          filteredTeams = teams;
          return buildTeamList();
        },
      )
          : allTeamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(allTeamsProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (data) {
          teams = mapTeams(data);
          filteredTeams = teams;
          return buildTeamList();
        },
      ),
    );
  }
}
