import 'package:beariscope/models/pits_map_data.dart';
import 'package:beariscope/models/pits_scouting_models.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pits_scouting_provider.g.dart';

//teams that are eligible for pits scouting (at the event and not already scouted)
final pitsTeamsProvider = Provider<AsyncValue<List<Team>>>((ref) {
  final teamsAsync = ref.watch(teamsProvider);
  return teamsAsync.whenData(parsePitsTeams);
});

//map of team number to team name for teams eligible for pits scouting
final pitsTeamNameMapProvider = Provider<Map<int, String>>((ref) {
  final teams = ref
      .watch(pitsTeamsProvider)
      .maybeWhen(data: (value) => value, orElse: () => const <Team>[]);
  return {for (final team in teams) team.number: team.name};
});

//teams that have been scouted
@riverpod
Set<int> pitsScouted(Ref ref) {
  final eventKey = ref.watch(currentEventProvider);
  final scoutingAsync = ref.watch(scoutingDataProvider);

  return scoutingAsync.maybeWhen(
    data:
        (docs) =>
        docs
            .where(
              (doc) =>
          doc.meta?['type'] == 'pits' &&
              doc.meta?['event'] == eventKey,
        )
            .map((doc) {
          final raw = doc.data['teamNumber'];
          if (raw is int) return raw;
          if (raw is num) return raw.toInt();
          if (raw is String) return int.tryParse(raw);
          return null;
        })
            .whereType<int>()
            .toSet(),
    orElse: () => {},
  );
}

//pits map
@riverpod
Future<PitsMapData> pitsMap(Ref ref) async {
  final eventKey = ref.watch(currentEventProvider);
  final client = ref.read(honeycombClientProvider);

  final response = await client.get<Map<String, dynamic>>(
      '/pits',
      queryParams: {'event': eventKey},
      cachePolicy: CachePolicy.networkFirst
  );

  return PitsMapData.fromJson(response);
}
