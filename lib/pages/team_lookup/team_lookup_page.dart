import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamLookupPage extends StatefulWidget {
  const TeamLookupPage({super.key});

  @override
  State<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends State<TeamLookupPage> {
  TextEditingController _searchTermTEC = TextEditingController();
  List<Widget> filteredTeamCards = [];

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
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search_rounded),
          trailing: [
            IconButton(
              icon: Icon(Icons.filter_list_rounded),
              tooltip: 'Filter & Sort',
              onPressed: () {},
              // onPressed: () {filter();},
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
      body: const Center(
        child: Column(
          children: filteredTeamCards;
        )
      ),
    );
  }
}

