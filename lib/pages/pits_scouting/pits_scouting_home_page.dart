import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_assets.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';

enum PitsScoutingFilter { allTeams, notScouted, scouted }

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<PitsScoutingHomePage> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
  List<Team> teams = [];
  List<Team> filteredTeams = [];
  final Set<String> _scoutedTeamKeys = <String>{};
  PitsScoutingFilter _statusFilter = PitsScoutingFilter.allTeams;

  bool isInt(String input) => int.tryParse(input) != null;

  void filter(String query) {
    final trimmed = query.trim();

    final queryFiltered =
        trimmed.isEmpty
            ? teams
            : isInt(trimmed)
            ? teams.where((t) => t.number.toString().contains(trimmed)).toList()
            : teams
                .where(
                  (t) =>
                      t.name.toLowerCase().contains(trimmed.toLowerCase()) ||
                      t.key.toLowerCase().contains(trimmed.toLowerCase()),
                )
                .toList();

    filteredTeams =
        queryFiltered.where((team) {
          final isScouted = _scoutedTeamKeys.contains(team.key);
          return switch (_statusFilter) {
            PitsScoutingFilter.allTeams => true,
            PitsScoutingFilter.notScouted => !isScouted,
            PitsScoutingFilter.scouted => isScouted,
          };
        }).toList();
  }

  List<Team> mapTeams(List<Map<String, dynamic>> data) {
    return data
        .map((json) => Team.fromJson(json))
        .where((team) => team.number > 0)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  Widget buildTeamList() {
    return BeariscopeCardList(
      children:
          filteredTeams
              .map(
                (team) => PitsScoutingTeamCard(
                  teamName: team.name,
                  teamNumber: team.number,
                  scouted: _scoutedTeamKeys.contains(team.key),
                  onScoutedChanged: (value) {
                    if (!value) return;
                    setState(() {
                      _scoutedTeamKeys.add(team.key);
                      filter(searchTermTEC.text);
                    });
                  },
                ),
              )
              .toList(),
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
    final selectedEvent = ref.watch(currentEventProvider);
    final teamsAsync = ref.watch(teamsProvider);

    Future<void> onRefresh() async {
      final client = ref.read(honeycombClientProvider);
      client.invalidateCache('/teams', queryParams: {'event': selectedEvent});
      ref.invalidate(teamsProvider);
      await ref.read(teamsProvider.future);
    }

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
          elevation: WidgetStatePropertyAll<double>(0),
          leading: const Icon(Symbols.search_rounded),
          trailing: [
            PopupMenuButton<PitsScoutingFilter>(
              icon: const Icon(Symbols.filter_list_rounded),
              tooltip: 'Filter & Sort',
              itemBuilder:
                  (context) => [
                    CheckedPopupMenuItem<PitsScoutingFilter>(
                      value: PitsScoutingFilter.allTeams,
                      checked: _statusFilter == PitsScoutingFilter.allTeams,
                      child: const Text('All Teams'),
                    ),
                    CheckedPopupMenuItem<PitsScoutingFilter>(
                      value: PitsScoutingFilter.notScouted,
                      checked: _statusFilter == PitsScoutingFilter.notScouted,
                      child: const Text('Not Scouted'),
                    ),
                    CheckedPopupMenuItem<PitsScoutingFilter>(
                      value: PitsScoutingFilter.scouted,
                      checked: _statusFilter == PitsScoutingFilter.scouted,
                      child: const Text('Scouted'),
                    ),
                  ],
              onSelected: (selection) {
                setState(() {
                  _statusFilter = selection;
                  filter(searchTermTEC.text);
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
        leading:
            main.isDesktop
                ? const SizedBox(width: 40)
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: main.openDrawer,
                ),
        actions: [SizedBox(width: 48)],
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(teamsProvider),
                child: const Text('Retry'),
              ),
            ),
        data: (data) {
          teams = mapTeams(data);
          filter(searchTermTEC.text);
          return RefreshIndicator(onRefresh: onRefresh, child: buildTeamList());
        },
      ),
    );
  }
}
