import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

final upcomingScheduleProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final client = ref.watch(honeycombClientProvider);
  final eventsFuture = client.get<List<dynamic>>(
    '/events?team=2046&year=2026&year=2025',
  );
  final matchesFuture = client.get<List<dynamic>>(
    '/matches?team=2046&year=2026&year=2025',
  );

  final results = await Future.wait([eventsFuture, matchesFuture]);

  final events =
      results[0]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  final matches =
      results[1]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  final matchesByEvent = <String, List<Map<String, dynamic>>>{};
  for (final match in matches) {
    final eventKey =
        match['eventKey']?.toString() ?? match['event_key']?.toString();
    if (eventKey != null && eventKey.isNotEmpty) {
      matchesByEvent.putIfAbsent(eventKey, () => []).add(match);
    }
  }

  for (final list in matchesByEvent.values) {
    list.sort((a, b) => _matchNumber(a).compareTo(_matchNumber(b)));
  }

  final schedule =
      events
          .map(
            (event) => <String, dynamic>{
              'event': event,
              'matches':
                  matchesByEvent[event['key']?.toString() ?? ''] ?? const [],
            },
          )
          .toList();

  schedule.sort((a, b) {
    final dateA =
        _parseDate(
          (a['event'] as Map<String, dynamic>)['startDate'] ??
              (a['event'] as Map<String, dynamic>)['start_date'],
        ) ??
        DateTime(9999);
    final dateB =
        _parseDate(
          (b['event'] as Map<String, dynamic>)['startDate'] ??
              (b['event'] as Map<String, dynamic>)['start_date'],
        ) ??
        DateTime(9999);
    return dateA.compareTo(dateB);
  });

  return schedule;
});

int _matchNumber(Map<String, dynamic> match) {
  final value = match['matchNumber'] ?? match['match_number'];
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
