import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/rankings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
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
    final selectedEvent = ref.watch(currentEventProvider);
    final teamsAsync = ref.watch(teamsProvider);
    final selectedSort = ref.watch(teamSortProvider);
    final rankingsAsync = ref.watch(eventRankingsProvider);
    final rankings = switch (rankingsAsync) {
      AsyncData(:final value) => value,
      _ => const <int, TeamRanking>{},
    };

    Future<void> onRefresh() async {
      final client = ref.read(honeycombClientProvider);
      client.invalidateCache('/teams', queryParams: {'event': selectedEvent});
      client.invalidateCache(
        '/rankings',
        queryParams: {'event': selectedEvent},
      );
      ref.invalidate(teamsProvider);
      ref.invalidate(eventRankingsProvider);
      try {
        await Future.wait([
          ref.read(teamsProvider.future),
          ref.read(eventRankingsProvider.future),
        ]);
      } catch (_) {
        // Keep current cached data visible if refresh fails.
      }
    }

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
            PopupMenuButton<TeamSort>(
              icon: Icon(Symbols.sort_rounded),
              tooltip: 'Sort',
              itemBuilder:
                  (context) =>
                      TeamSort.values
                          .map(
                            (sort) => CheckedPopupMenuItem<TeamSort>(
                              value: sort,
                              checked: selectedSort == sort,
                              child: Text(sort.label),
                            ),
                          )
                          .toList(),
              onSelected: (TeamSort newSort) {
                ref.read(teamSortProvider.notifier).setSort(newSort);
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
          final teamList =
              teams
                  .whereType<Map<String, dynamic>>()
                  .map((json) => Team.fromJson(json))
                  .toList();

          final searchTerm = _searchTermTEC.text.trim().toLowerCase();
          var filteredTeams =
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

          // Apply sort
          filteredTeams = List.of(filteredTeams);
          switch (selectedSort) {
            case TeamSort.teamNumberAsc:
              filteredTeams.sort((a, b) => a.number.compareTo(b.number));
            case TeamSort.teamNumberDesc:
              filteredTeams.sort((a, b) => b.number.compareTo(a.number));
            case TeamSort.rankAsc:
              filteredTeams.sort((a, b) {
                // Teams without a rank go to the end
                final rankA = rankings[a.number]?.rank ?? 999999;
                final rankB = rankings[b.number]?.rank ?? 999999;
                return rankA.compareTo(rankB);
              });
            case TeamSort.rankDesc:
              filteredTeams.sort((a, b) {
                final rankA = rankings[a.number]?.rank ?? 0;
                final rankB = rankings[b.number]?.rank ?? 0;
                return rankB.compareTo(rankA);
              });
          }

          if (filteredTeams.isEmpty) {
            return const Center(child: Text('No teams found'));
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: BeariscopeCardList(
              children:
                  filteredTeams
                      .map((team) => TeamCard(teamKey: team.key))
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}
