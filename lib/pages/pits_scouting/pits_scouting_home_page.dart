import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/pits_scouting/pits_map_view.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_assets.dart';
import 'package:beariscope/models/pits_scouting_models.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/pits_scouting_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/components/beariscope_card.dart';

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<PitsScoutingHomePage> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
  PitsScoutingFilter _statusFilter = PitsScoutingFilter.allTeams;

  /// Whether to show the interactive map view (true) or the list view (false).
  // default to list view instead of map
  bool _showMapView = false;

  void _openScoutingForm(
    BuildContext context,
    int teamNumber,
    String teamName,
    bool scouted,
  ) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => PitsScoutingFormPage(
              teamNumber: teamNumber,
              teamName: teamName,
              scouted: scouted,
            ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh cross-device scouted status from honeycomb.
        ref.read(scoutingDataProvider.notifier).refresh();
      }
    });
  }

  final TextEditingController _searchTEC = TextEditingController();

  @override
  void dispose() {
    _searchTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);
    final selectedEvent = ref.watch(currentEventProvider);
    final teamsAsync = ref.watch(pitsTeamsProvider);
    final scoutedNums = ref.watch(pitsScoutedProvider);
    final teamNameMap = ref.watch(pitsTeamNameMapProvider);

    Future<void> onRefresh() async {
      final client = ref.read(honeycombClientProvider);
      client.invalidateCache('/teams', queryParams: {'event': selectedEvent});
      client.invalidateCache('/pits', queryParams: {'event': selectedEvent});
      ref.invalidate(pitsTeamsProvider);
      ref.invalidate(pitsMapProvider);
      await ref.read(scoutingDataProvider.notifier).refresh();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: !_showMapView,
        titleSpacing: !_showMapView ? 8.0 : 16.0,
        title:
            _showMapView
                ? const Text('Pits Map')
                : SearchBar(
                  controller: _searchTEC,
                  hintText: 'Team name or number',
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  elevation: const WidgetStatePropertyAll<double>(0),
                  leading: const Icon(Symbols.search_rounded),
                  trailing: [
                    PopupMenuButton<PitsScoutingFilter>(
                      icon: const Icon(Symbols.filter_list_rounded),
                      tooltip: 'Filter & Sort',
                      itemBuilder:
                          (context) => [
                            CheckedPopupMenuItem<PitsScoutingFilter>(
                              value: PitsScoutingFilter.allTeams,
                              checked:
                                  _statusFilter == PitsScoutingFilter.allTeams,
                              child: const Text('All Teams'),
                            ),
                            CheckedPopupMenuItem<PitsScoutingFilter>(
                              value: PitsScoutingFilter.notScouted,
                              checked:
                                  _statusFilter ==
                                  PitsScoutingFilter.notScouted,
                              child: const Text('Not Scouted'),
                            ),
                            CheckedPopupMenuItem<PitsScoutingFilter>(
                              value: PitsScoutingFilter.scouted,
                              checked:
                                  _statusFilter == PitsScoutingFilter.scouted,
                              child: const Text('Scouted'),
                            ),
                          ],
                      onSelected: (selection) {
                        setState(() {
                          _statusFilter = selection;
                        });
                      },
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
        leading:
            main.isDesktop
                ? (!_showMapView ? const SizedBox(width: 40) : null)
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: main.openDrawer,
                ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 8),
        actions: [
          IconButton(
            tooltip:
                _showMapView ? 'Switch to list view' : 'Switch to map view',
            icon: Icon(
              _showMapView ? Symbols.list_rounded : Symbols.map_rounded,
            ),
            onPressed: () => setState(() => _showMapView = !_showMapView),
          ),
        ],
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(pitsTeamsProvider),
                child: const Text('Retry'),
              ),
            ),
        data: (teams) {
          final filteredTeams = filterPitsTeams(
            teams: teams,
            query: _searchTEC.text,
            scoutedTeamNumbers: scoutedNums,
            statusFilter: _statusFilter,
          );

          if (_showMapView) {
            return _buildMapView(
              context,
              onRefresh: onRefresh,
              scoutedNums: scoutedNums,
              teamNameMap: teamNameMap,
            );
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: _buildTeamList(context, filteredTeams, scoutedNums),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Map view
  // --------------------------------------------------------------------------

  Widget _buildMapView(
    BuildContext context, {
    required Future<void> Function() onRefresh,
    required Set<int> scoutedNums,
    required Map<int, String> teamNameMap,
  }) {
    final pitsMapAsync = ref.watch(pitsMapProvider);

    return pitsMapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildMapError(context, onRefresh),
      data: (mapData) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          // RefreshIndicator needs a scrollable child; wrap PitsMapView in a
          // LayoutBuilder + Stack with a hidden ListView for scroll detection.
          child: Stack(
            children: [
              // Invisible scrollable so RefreshIndicator triggers.
              ListView(physics: const AlwaysScrollableScrollPhysics()),
              PitsMapView(
                mapData: mapData,
                scoutedTeams: scoutedNums,
                teamNames: teamNameMap,
                onTeamTap: (teamNum, teamName) {
                  _openScoutingForm(
                    context,
                    teamNum,
                    teamName,
                    scoutedNums.contains(teamNum),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapError(
    BuildContext context,
    Future<void> Function() onRefresh,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.fmd_bad_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Pit map unavailable',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The Nexus pit map for this event has not been published yet.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(pitsMapProvider);
                  },
                  icon: const Icon(Symbols.refresh_rounded),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showMapView = false),
                  icon: const Icon(Symbols.list_rounded),
                  label: const Text('Show List'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // List view (original behaviour, now scouted status from provider)
  // --------------------------------------------------------------------------

  Widget _buildTeamList(
    BuildContext context,
    List<Team> filteredTeams,
    Set<int> scoutedNums,
  ) {
    return BeariscopeCardList(
      children:
          filteredTeams
              .map(
                (team) => PitsScoutingTeamCard(
                  teamName: team.name,
                  teamNumber: team.number,
                  scouted: scoutedNums.contains(team.number),
                  onScoutedChanged: (value) {
                    if (!value) return;
                    // The provider updates automatically; just refresh it.
                    ref.read(scoutingDataProvider.notifier).refresh();
                  },
                ),
              )
              .toList(),
    );
  }
}
