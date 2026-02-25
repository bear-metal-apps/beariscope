import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

// helper to convert dynamic list to string key maps
List<Map<String, dynamic>> _toStringKeyMaps(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

// fetch all available events for the team
final picklistEventsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(honeycombClientProvider);
  
  final eventsData = await client.get<List<dynamic>>(
    '/events?team=2046&year=2026',
  );

  return _toStringKeyMaps(eventsData);
});

// fetch teams for a specific event
final teamsForEventProvider = FutureProvider.family<
    List<Map<String, dynamic>>,
    String>((ref, eventKey) async {
  final client = ref.watch(honeycombClientProvider);
  
  final teamData = await client.get<List<dynamic>>(
    '/teams?event=$eventKey',
  );

  return _toStringKeyMaps(teamData);
});
