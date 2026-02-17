import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/components/team_card.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';

class TeamLookupPage extends ConsumerStatefulWidget {
  const TeamLookupPage({super.key});

  @override
  ConsumerState<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends ConsumerState<TeamLookupPage> {
  final TextEditingController _searchTermTEC = TextEditingController();

  @override
  void dispose() {
    _searchTermTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);
    final teamsAsync = ref.watch(teamsProvider);
    final selectedFilter = ref.watch(teamFilterProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: _searchTermTEC,
          onChanged: (_) => setState(() {}),
          hintText: 'Team name or number',
          elevation: WidgetStateProperty.all(0.0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Symbols.search_rounded),
          trailing: [
            PopupMenuButton<TeamFilter>(
              icon: Icon(Symbols.filter_list_rounded),
              tooltip: 'Filter & Sort',
              itemBuilder:
                  (context) => [
                    CheckedPopupMenuItem<TeamFilter>(
                      value: TeamFilter.allEvents,
                      checked: selectedFilter == TeamFilter.allEvents,
                      child: Text('All Events'),
                    ),
                    CheckedPopupMenuItem<TeamFilter>(
                      value: TeamFilter.currentEventOnly,
                      checked: selectedFilter == TeamFilter.currentEventOnly,
                      child: Text('Current Event Only'),
                    ),
                  ],
              onSelected: (TeamFilter newFilter) {
                ref.read(teamFilterProvider.notifier).setFilter(newFilter);
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
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (teams) {
          // convert raw maps into Team objects
          final teamList =
              teams
                  .whereType<Map<String, dynamic>>()
                  .map((json) => Team.fromJson(json))
                  .toList();

          final searchTerm = _searchTermTEC.text.trim().toLowerCase();
          final filteredTeams =
              searchTerm.isEmpty
                  ? teamList
                  : teamList.where((team) {
                    final teamName = team.name.toLowerCase();
                    final teamNumber = team.number.toString();
                    final teamKey = team.key.toLowerCase();
                    return teamName.contains(searchTerm) ||
                        teamNumber.contains(searchTerm) ||
                        teamKey.contains(searchTerm);
                  }).toList();

          if (filteredTeams.isEmpty) {
            return const Center(child: Text('No teams found'));
          }

          return BeariscopeCardList(
            children:
                filteredTeams
                    .map((team) => TeamCard(teamKey: team.key))
                    .toList(),
          );
        },
      ),
    );
  }
}

enum Filter { allEvents, currentEventsOnly }
