import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:beariscope/providers/current_event_provider.dart';

enum TeamFilter { allEvents, currentEventOnly }

// simple class to manage filter state
class TeamFilterNotifier extends Notifier<TeamFilter> {
  @override
  TeamFilter build() => TeamFilter.allEvents;

  void setFilter(TeamFilter newFilter) {
    state = newFilter;
  }
}

// provider to manage filter state
final teamFilterProvider = NotifierProvider<TeamFilterNotifier, TeamFilter>(
  () => TeamFilterNotifier(),
);

List<Map<String, dynamic>> _toStringKeyMaps(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

// i moved each logic out of the single teamsProvider so that pits scouting can piggyback off of this cleaner -jack
final allEventsTeamsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final client = ref.watch(honeycombClientProvider);

  final eventsData = await client.get<List<dynamic>>(
    '/events?team=2046&year=2026',
  );

  final events = _toStringKeyMaps(eventsData);
  if (events.isEmpty) {
    return [];
  }

  final allTeams = <String, Map<String, dynamic>>{};

  for (final event in events) {
    final eventKey = (event['key'] ?? '').toString();
    if (eventKey.isEmpty) continue;

    final teamData = await client.get<List<dynamic>>('/teams?event=$eventKey');

    for (final team in _toStringKeyMaps(teamData)) {
      final teamKey = (team['key'] ?? team['team_key'] ?? '').toString();
      if (teamKey.isNotEmpty) {
        allTeams[teamKey] = team;
      }
    }
  }

  return allTeams.values.toList();
});

final currentEventTeamsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final selectedEvent = ref.watch(currentEventProvider);
  final client = ref.watch(honeycombClientProvider);

  final eventsData = await client.get<List<dynamic>>(
    '/events?team=2046&year=2026',
  );

  final events = _toStringKeyMaps(eventsData);
  if (events.isEmpty) {
    return [];
  }

  final eventKey = selectedEvent ?? (events.first['key'] ?? '').toString();
  if (eventKey.isEmpty) {
    return [];
  }

  final teamData = await client.get<List<dynamic>>('/teams?event=$eventKey');
  return _toStringKeyMaps(teamData);
});

// fetch teams based on current filter
final teamsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final filter = ref.watch(teamFilterProvider);

  if (filter == TeamFilter.currentEventOnly) {
    return ref.watch(currentEventTeamsProvider.future);
  } else {
    return ref.watch(allEventsTeamsProvider.future);
  }
});
