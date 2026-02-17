import 'package:animations/animations.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';

class TeamCard extends ConsumerWidget {
  final String teamKey;
  final double? height;

  const TeamCard({super.key, required this.teamKey, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsProvider);

    return teamsAsync.when(
      loading: () => _loadingCard(context),
      error: (err, stack) => _errorCard(context, err),
      data: (teams) {
        // convert raw maps into Team objects
        final teamList =
            teams
                .whereType<Map<String, dynamic>>()
                .map((json) => Team.fromJson(json))
                .toList();

        // find the matching team
        Team? team;
        for (final t in teamList) {
          if (t.key == teamKey || t.number.toString() == teamKey) {
            team = t;
            break;
          }
        }

        if (team == null) {
          return _errorCard(context, "Team not found");
        }

        return _teamCard(context, team);
      },
    );
  }

  Widget _loadingCard(BuildContext context) {
    return SizedBox(
      height: height ?? 256,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorCard(BuildContext context, Object error) {
    return SizedBox(
      height: height ?? 256,
      child: Center(child: Text("Error: $error")),
    );
  }

  Widget _teamCard(BuildContext context, Team team) {
    return OpenContainer(
      useRootNavigator: true,
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      middleColor: Theme.of(context).scaffoldBackgroundColor,
      closedColor: Theme.of(context).colorScheme.surfaceContainer,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedBuilder: (context, action) {
        return SizedBox(
          height: height ?? 256,
          width: double.infinity,
          child: InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 52,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Xolonium',
                        ),
                      ),
                      Text(
                        team.number.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return TeamDetailsPage(
          teamName: team.name,
          teamNumber: team.number.toString(),
        );
      },
    );
  }
}

class TeamDetailsPage extends ConsumerWidget {
  final String teamName;
  final String teamNumber;

  const TeamDetailsPage({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text('$teamName - $teamNumber'),
              leading: IconButton(
                icon: const Icon(Symbols.close),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Averages'),
                  Tab(text: 'Breakdown'),
                  Tab(text: 'Notes'),
                  Tab(text: 'Capabilities'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                Center(child: Text('Averages content')),
                Center(child: Text('Breakdown content')),
                Center(child: Text('Notes content')),
                Center(child: Text('Capabilities content')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
