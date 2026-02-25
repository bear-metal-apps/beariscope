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
    // Re-runs automatically whenever the selected event changes.
    final eventKey = ref.watch(currentEventProvider);

    // Return cached data immediately so the UI isn't blocked on the network.
    final cached = _loadFromHive(eventKey);

    // Sync in the background; state updates when the fetch completes.
    // Errors are swallowed here because the cached list is already showing.
    _syncInBackground(eventKey);

    return cached;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Reads all documents from the Hive box that belong to [eventKey].
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

  /// Fetches from the API and upserts into Hive by `_id`, then updates state.
  /// Called fire-and-forget from [build]; errors are silently ignored.
  Future<void> _syncInBackground(String eventKey) async {
    try {
      await _fetchAndUpsert(eventKey);
      state = AsyncData(_loadFromHive(eventKey));
    } catch (_) {
      // Already showing cached data — don't replace it with an error state.
    }
  }

  /// Fetches `GET /api/scouting?event=<eventKey>` and upserts all returned
  /// documents into the Hive box, keyed by their `_id`.
  Future<void> _fetchAndUpsert(String eventKey) async {
    final client = ref.read(honeycombClientProvider);
    final response = await client.get<Map<String, dynamic>>(
      '/scouting?event=${Uri.encodeComponent(eventKey)}',
      forceRefresh: true,
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

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Manually force a full re-fetch from the API for the current event.
  /// Merges results into the local store (upsert by `_id`).
  /// Throws on network or API error so callers can surface feedback to the user.
  Future<void> refresh() async {
    final eventKey = ref.read(currentEventProvider);
    await _fetchAndUpsert(eventKey);
    state = AsyncData(_loadFromHive(eventKey));
  }
}
