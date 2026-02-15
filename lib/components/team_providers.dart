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

// fetch teams based on current filter
final teamsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final filter = ref.watch(teamFilterProvider);
  final selectedEvent = ref.watch(currentEventProvider);

  // fetch events to know which events exist
  final eventsData = await ref.watch(
    getListDataProvider(
      endpoint: '/events?team=2046&year=2026&year=2025',
      forceRefresh: true,
    ).future,
  );

  final events = eventsData.whereType<Map<String, dynamic>>().toList();
  if (events.isEmpty) {
    return [];
  }

  if (filter == TeamFilter.currentEventOnly) {
    // use the selected event from settings, or default to first event
    final eventKey = selectedEvent ?? (events.first['key'] ?? '').toString();
    if (eventKey.isEmpty) {
      return [];
    }

    final teamData = await ref.watch(
      getListDataProvider(
        endpoint: '/teams?event=$eventKey',
        forceRefresh: true,
      ).future,
    );

    return teamData.whereType<Map<String, dynamic>>().toList();
  } else {
    // fetch teams from all events and unduplicate by key
    final allTeams = <String, Map<String, dynamic>>{};

    for (final event in events) {
      final eventKey = (event['key'] ?? '').toString();
      if (eventKey.isEmpty) continue;

      final teamData = await ref.watch(
        getListDataProvider(
          endpoint: '/teams?event=$eventKey',
          forceRefresh: true,
        ).future,
      );

      for (final team in teamData.whereType<Map<String, dynamic>>()) {
        final teamKey = (team['key'] ?? team['team_key'] ?? '').toString();
        if (teamKey.isNotEmpty) {
          allTeams[teamKey] = team;
        }
      }
    }

    return allTeams.values.toList();
  }
});
