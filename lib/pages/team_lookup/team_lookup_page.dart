import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/components/team_card.dart';

class TeamLookupPage extends StatefulWidget {
  const TeamLookupPage({super.key});

  @override
  State<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends State<TeamLookupPage> {
  final TextEditingController _searchTermTEC = TextEditingController();
  List<Widget> filteredTeamCards = [
    TeamCard(teamName: 'Bear Metal', teamNumber: '2046'),
    TeamCard(teamName: 'Riptide Robotics', teamNumber: '8267'),
    TeamCard(teamName: 'Madcows!', teamNumber: '276'),
    TeamCard(teamName: 'Vikings', teamNumber: '9289'),
    TeamCard(teamName: 'The Vo', teamNumber: '4650'),
  ];
  Filter filter = Filter.allEvents;

  // final allTeamCards = ref.read(teamCardListNotifierProvider);
  // final filteredTeamCards = ref.read(filteredListNotifierProvider);
  //
  // void filter() {
  //   int _intSearchTerm = int.tryParse(_searchTermTEC.text) ?? -1;
  //   ref.read(filteredListNotifierProvider.notifier).reset();
  //   if (_intSearchTerm < 0) {
  //     for (TeamCard checkedCard in allTeamCards) {
  //       if (checkedCard.teamNumber.contains('$_searchTermTEC')) {
  //         ref.read(filteredListNotifierProvider.notifier).addCard(searchedCard);
  //   } else {
  //     for (TeamCard checkedCard in allTeamCards) {
  //       if (checkedCard.teamName.contains('$_searchTermTEC')) {
  //         ref.read(filteredListNotifierProvider.notifier).addCard(searchedCard);
  //   }
  // }

  // void filter(String filterValue)
  // Uses the values within a class Team and matches it with filterValue and
  // changes filteredTeamCards based on if it matches
  // Note: filteredTeamCards will eventually be a Provider<List<TeamCard>> so
  // I can use a function addTeam(Team team) with state = [...state, team];

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: _searchTermTEC,
          hintText: 'Team name or number',
          elevation: WidgetStateProperty.all(0.0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Symbols.search_rounded),
          trailing: [
            PopupMenuButton(
              icon: Icon(Symbols.filter_list_rounded),
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
                  filter = newValue;
                });
              },
            ),
          ],
        ),
        leading:
            main.isDesktop
                ? SizedBox(width: 48)
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: main.openDrawer,
                ),
        actions: [SizedBox(width: 48)],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(spacing: 16, children: filteredTeamCards),
          ),
        ),
      ),
    );
  }
}

enum Filter { allEvents, currentEventsOnly }
