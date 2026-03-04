import 'dart:convert';

import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scouting_data_provider.g.dart';

@Riverpod(keepAlive: true)
class ScoutingData extends _$ScoutingData {
  static const _boxName = 'scouting_data';

  @override
  Future<List<ScoutingDocument>> build() async {
    final eventKey = ref.watch(currentEventProvider);

    final cached = _loadFromHive(eventKey);

    _syncInBackground(eventKey);

    return cached;
  }

  List<ScoutingDocument> _loadFromHive(String eventKey) {
    final box = Hive.box<String>(_boxName);
    return box.values
        .map((raw) {
          try {
            return ScoutingDocument.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ScoutingDocument>()
        .where((doc) => doc.meta?['event'] == eventKey)
        .toList();
  }

  Future<void> _syncInBackground(String eventKey) async {
    try {
      await _fetchAndUpsert(eventKey);
      state = AsyncData(_loadFromHive(eventKey));
    } catch (_) {
      // Already showing cached data — don't replace it with an error state.
    }
  }

  Future<void> _fetchAndUpsert(String eventKey) async {
    final client = ref.read(honeycombClientProvider);
    final response = await client.get<Map<String, dynamic>>(
      '/scouting?event=${Uri.encodeComponent(eventKey)}',
      cachePolicy: CachePolicy.networkFirst,
    );

    final rawList =
        (response['data'] as List?)?.whereType<Map>().toList() ?? [];

    final box = Hive.box<String>(_boxName);
    for (final raw in rawList) {
      final map = Map<String, dynamic>.from(raw);
      final id = map['_id']?.toString();
      if (id != null && id.isNotEmpty) {
        box.put(id, jsonEncode(map));
      }
    }
  }

  Future<void> refresh() async {
    final eventKey = ref.read(currentEventProvider);
    await _fetchAndUpsert(eventKey);
    state = AsyncData(_loadFromHive(eventKey));
  }
}
