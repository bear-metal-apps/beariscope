import 'package:beariscope/components/team_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/components/team_card.dart';
import 'package:beariscope/components/team_model.dart';

class TeamLookupPage extends ConsumerStatefulWidget {
  const TeamLookupPage({super.key});

  @override
  ConsumerState<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends ConsumerState<TeamLookupPage> {
  final TextEditingController _searchTermTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);
    final teamsAsync = ref.watch(teamsProvider);

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
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: TeamFilter.allEvents,
                  child: Text('All Events'),
                ),
                PopupMenuItem(
                  value: TeamFilter.currentEventOnly,
                  child: Text('Current Event Only'),
                ),

              ],
              onSelected: (TeamFilter newFilter) {
                ref.read(teamFilterProvider.notifier).setFilter(newFilter);
              },

            ),
          ],
        ),
        leading: main.isDesktop
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
          final teamList = teams
              .whereType<Map<String, dynamic>>()
              .map((json) => Team.fromJson(json))
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: teamList.map((team) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TeamCard(teamKey: team.key),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum Filter { allEvents, currentEventsOnly }
