import 'package:beariscope/pages/team_lookup/tabs/scouting_tab_widgets.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class NotesTab extends ConsumerWidget {
  final int teamNumber;

  const NotesTab({super.key, required this.teamNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamScoutingProvider(teamNumber));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bundle) => _NotesBody(bundle: bundle),
    );
  }
}

class _NotesBody extends StatelessWidget {
  final TeamScoutingBundle bundle;

  const _NotesBody({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final feedItems = <_FeedItem>[];

    final sortedDocs = [...bundle.matchDocs]..sort((a, b) {
      final na = TeamScoutingBundle.matchNumber(a);
      final nb = TeamScoutingBundle.matchNumber(b);
      if (na != null && nb != null) return na.compareTo(nb);
      if (na != null) return -1;
      if (nb != null) return 1;
      return a.timestamp.compareTo(b.timestamp);
    });

    int totalAStop = 0;
    int totalEStop = 0;
    int totalCommsLoss = 0;
    int totalCollisions = 0;
    int totalFouls = 0;

    for (final doc in sortedDocs) {
      if (_field(doc, kSectionAuto, kAutoAStop) == true) totalAStop++;
      if (_field(doc, kSectionTele, kTeleEStop) == true) totalEStop++;
      if (_field(doc, kSectionTele, kTeleLostComms) == true) totalCommsLoss++;
      if (_field(doc, kSectionAuto, kAutoCollided) == true) totalCollisions++;
      final f = _field(doc, kSectionEndgame, kEndFouls);
      if (f is num) totalFouls += f.toInt();

      final notes =
          _field(doc, kSectionEndgame, kEndNotes)?.toString().trim() ?? '';
      final mn = TeamScoutingBundle.matchNumber(doc);
      final matchLabel =
          mn != null
              ? 'Match $mn'
              : 'Match (${scoutingShortDate(doc.timestamp)})';
      final scoutedBy = doc.meta?['scoutedBy']?.toString() ?? '';

      feedItems.add(
        _FeedItem(
          sourceLabel: matchLabel,
          scoutedBy: scoutedBy,
          notes: notes,
          incidents: [
            if (_field(doc, kSectionAuto, kAutoAStop) == true) 'A-Stop',
            if (_field(doc, kSectionTele, kTeleEStop) == true) 'E-Stop',
            if (_field(doc, kSectionTele, kTeleLostComms) == true) 'Comms Loss',
            if (_field(doc, kSectionAuto, kAutoCollided) == true) 'Collision',
            if (f is num && f > 0) '${f.toInt()} Foul${f == 1 ? '' : 's'}',
          ],
          timestamp: doc.timestamp,
        ),
      );
    }

    if (bundle.hasPitsData) {
      final pitsNotes = bundle.pitsDoc!.data['notes']?.toString().trim() ?? '';
      final scoutedBy = bundle.pitsDoc!.meta?['scoutedBy']?.toString() ?? '';
      feedItems.add(
        _FeedItem(
          sourceLabel: 'Pits',
          scoutedBy: scoutedBy,
          notes: pitsNotes,
          incidents: const [],
          timestamp: bundle.pitsDoc!.timestamp,
        ),
      );
    }

    // TODO(strat): add strat notes entry once strat data is implemented.

    final hasAnyContent = feedItems.any(
      (f) => f.notes.isNotEmpty || f.incidents.isNotEmpty,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Incident summary.
        const ScoutingSectionHeader(
          title: 'Incident Summary',
          icon: Symbols.warning_amber_rounded,
        ),
        const SizedBox(height: kScoutingHeaderGap),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                scoutingIncidentCountChip(context, 'A-Stops', totalAStop),
                scoutingIncidentCountChip(context, 'E-Stops', totalEStop),
                scoutingIncidentCountChip(
                  context,
                  'Comms Loss',
                  totalCommsLoss,
                ),
                scoutingIncidentCountChip(
                  context,
                  'Collisions',
                  totalCollisions,
                ),
                scoutingIncidentCountChip(context, 'Total Fouls', totalFouls),
              ],
            ),
          ),
        ),
        const SizedBox(height: kScoutingSectionGap),
        if (!hasAnyContent)
          const Center(heightFactor: 5, child: Text('No notes recorded.'))
        else ...[
          const ScoutingSectionHeader(
            title: 'Notes',
            icon: Symbols.notes_rounded,
          ),
          const SizedBox(height: kScoutingHeaderGap),
          // TODO(strat): insert strat notes section once strat data is available.
          ...feedItems
              .where((f) => f.notes.isNotEmpty || f.incidents.isNotEmpty)
              .map((item) => _FeedItemTile(item: item)),
        ],
      ],
    );
  }

  static dynamic _field(ScoutingDocument doc, String section, String fieldId) =>
      TeamScoutingBundle.getMatchField(doc, section, fieldId);
}

class _FeedItem {
  final String sourceLabel;
  final String scoutedBy;
  final String notes;
  final List<String> incidents;
  final DateTime timestamp;

  const _FeedItem({
    required this.sourceLabel,
    required this.scoutedBy,
    required this.notes,
    required this.incidents,
    required this.timestamp,
  });
}

class _FeedItemTile extends StatelessWidget {
  final _FeedItem item;

  const _FeedItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.sourceLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (item.scoutedBy.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '— ${item.scoutedBy}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            if (item.incidents.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    item.incidents
                        .map((i) => scoutingIncidentChip(context, i))
                        .toList(),
              ),
            ],
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.notes, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
