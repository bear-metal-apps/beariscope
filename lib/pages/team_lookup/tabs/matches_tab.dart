import 'package:beariscope/pages/team_lookup/tabs/scouting_tab_widgets.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class MatchesTab extends ConsumerWidget {
  final int teamNumber;

  const MatchesTab({super.key, required this.teamNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamScoutingProvider(teamNumber));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bundle) => _MatchesBody(bundle: bundle),
    );
  }
}

class _MatchesBody extends StatelessWidget {
  final TeamScoutingBundle bundle;

  const _MatchesBody({required this.bundle});

  @override
  Widget build(BuildContext context) {
    if (!bundle.hasMatchData) {
      return const Center(child: Text('No match data recorded for this team.'));
    }

    // Sort: known match numbers ascending, then unknowns by timestamp.
    final sorted = [...bundle.matchDocs]..sort((a, b) {
      final mn = TeamScoutingBundle.matchNumber(a);
      final mbn = TeamScoutingBundle.matchNumber(b);
      if (mn != null && mbn != null) return mn.compareTo(mbn);
      if (mn != null) return -1;
      if (mbn != null) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _MatchCard(doc: sorted[i]),
    );
  }
}

// ─── Match card ───────────────────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  final ScoutingDocument doc;

  const _MatchCard({required this.doc});

  dynamic _f(String section, String id) =>
      TeamScoutingBundle.getMatchField(doc, section, id);

  @override
  Widget build(BuildContext context) {
    final mn = TeamScoutingBundle.matchNumber(doc);
    final label =
        mn != null
            ? 'Match $mn'
            : 'Match (${scoutingShortDate(doc.timestamp)})';

    final autoFuel = _f(kSectionAuto, kAutoFuelScored);
    final teleFuel = _f(kSectionTele, kTeleFuelScored);
    final teleAccuracy = _f(kSectionTele, kTeleFuelAccuracy);
    final climb = _f(kSectionEndgame, kEndClimb);
    final climbLoc = _f(kSectionEndgame, kEndClimbLocation)?.toString();

    final fouls = _f(kSectionEndgame, kEndFouls);
    final foulsCount = fouls is num ? fouls.toInt() : 0;

    final incidents = [
      if (_f(kSectionAuto, kAutoAStop) == true)
        scoutingIncidentChip(context, 'A-Stop'),
      if (_f(kSectionTele, kTeleEStop) == true)
        scoutingIncidentChip(context, 'E-Stop'),
      if (_f(kSectionTele, kTeleLostComms) == true)
        scoutingIncidentChip(context, 'Comms Loss'),
      if (_f(kSectionAuto, kAutoCollided) == true)
        scoutingIncidentChip(context, 'Collision'),
      if (foulsCount > 0)
        scoutingIncidentChip(
          context,
          '$foulsCount Foul${foulsCount == 1 ? '' : 's'}',
        ),
    ];

    // Summary subtitle shown in the collapsed tile.
    final autoStr = autoFuel is num ? autoFuel.toInt().toString() : '—';
    final teleStr = teleFuel is num ? teleFuel.toInt().toString() : '—';
    final accStr =
        teleAccuracy is num ? '${teleAccuracy.toStringAsFixed(0)}%' : '—';
    final climbStr =
        (climb == null || climb.toString().isEmpty)
            ? '—'
            : (climbLoc != null && climbLoc.isNotEmpty
                ? '$climb ($climbLoc)'
                : climb.toString());

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        visualDensity: const VisualDensity(vertical: -2),
        title: Row(
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (incidents.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(spacing: 4, runSpacing: 2, children: incidents),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Auto $autoStr  •  Tele $teleStr  •  Acc $accStr  •  $climbStr',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [const Divider(height: 1), _MatchDetailSection(doc: doc)],
      ),
    );
  }
}

// ─── Match detail section ─────────────────────────────────────────────────────

/// Expanded detail rows for a single match document, grouped by game phase.
class _MatchDetailSection extends StatelessWidget {
  final ScoutingDocument doc;

  const _MatchDetailSection({required this.doc});

  dynamic _f(String section, String id) =>
      TeamScoutingBundle.getMatchField(doc, section, id);

  String _quadrants() {
    final qs = [
      if (_f(kSectionAuto, kAutoQuadrant1) == true) 'Q1',
      if (_f(kSectionAuto, kAutoQuadrant2) == true) 'Q2',
      if (_f(kSectionAuto, kAutoQuadrant3) == true) 'Q3',
      if (_f(kSectionAuto, kAutoQuadrant4) == true) 'Q4',
    ];
    return qs.isEmpty ? '—' : qs.join(', ');
  }

  /// Formats any field value for display.
  ///
  /// Booleans become "Yes"/"No"; null or empty strings become "—".
  /// An optional [format] callback is applied to numeric values.
  static String _fmt(dynamic v, {String Function(num)? format}) {
    if (v == null) return '—';
    if (v is bool) return v ? 'Yes' : 'No';
    if (v.toString().isEmpty) return '—';
    if (v is num && format != null) return format(v);
    return v.toString();
  }

  Widget _row(
    BuildContext context,
    String label,
    dynamic v, {
    String Function(num)? format,
  }) => ScoutingDataRow(label: label, value: _fmt(v, format: format));

  /// Wraps a list of rows in a phase card matching the capabilities card style.
  Widget _phaseSection(
    BuildContext context, {
    required Widget header,
    required List<Widget> rows,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, ...rows],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _phaseSection(
            context,
            header: const ScoutingSubHeader(
              title: 'Auto',
              icon: Symbols.timer_rounded,
            ),
            rows: [
              _row(context, 'Fuel Scored', _f(kSectionAuto, kAutoFuelScored)),
              _row(context, 'Fuel Passed', _f(kSectionAuto, kAutoFuelPassed)),
              _row(
                context,
                'Accuracy',
                _f(kSectionAuto, kAutoFuelAccuracy),
                format: (v) => '${v.toStringAsFixed(0)}%',
              ),
              _row(
                context,
                'Start Position',
                _f(kSectionAuto, kAutoStartPositions),
              ),
              _row(context, 'L1 Climb', _f(kSectionAuto, kAutoClimbL1)),
              _row(
                context,
                'Under Trench',
                _f(kSectionAuto, kAutoTraveledUnderTrench),
              ),
              _row(
                context,
                'Over Bump',
                _f(kSectionAuto, kAutoTraveledOverBump),
              ),
              _row(
                context,
                'Collected from Depot',
                _f(kSectionAuto, kAutoCollectFromDepot),
              ),
              _row(
                context,
                'Collected from Outpost',
                _f(kSectionAuto, kAutoCollectFromOutpost),
              ),
              _row(context, 'Quadrants', _quadrants()),
              _row(context, 'A-Stop', _f(kSectionAuto, kAutoAStop)),
              _row(context, 'Collided', _f(kSectionAuto, kAutoCollided)),
            ],
          ),
          _phaseSection(
            context,
            header: const ScoutingSubHeader(
              title: 'Teleop',
              icon: Symbols.gamepad_rounded,
            ),
            rows: [
              _row(context, 'Fuel Scored', _f(kSectionTele, kTeleFuelScored)),
              _row(context, 'Fuel Passed', _f(kSectionTele, kTeleFuelPassed)),
              _row(context, 'Fuel Poached', _f(kSectionTele, kTeleFuelPoached)),
              _row(
                context,
                'Accuracy',
                _f(kSectionTele, kTeleFuelAccuracy),
                format: (v) => '${v.toStringAsFixed(0)}%',
              ),
              _row(
                context,
                'Inactive Passing',
                _f(kSectionTele, kTeleInactivePassing),
              ),
              _row(
                context,
                'Collecting Time',
                _f(kSectionTele, kTeleCollecting),
                format: (v) => '${v.toStringAsFixed(1)} s',
              ),
              _row(
                context,
                'Full-Hopper Periods',
                _f(kSectionTele, kTelePeriodStartedWithFullHopper),
              ),
              _row(context, 'Over Bump', _f(kSectionTele, kTeleOverBump)),
              _row(context, 'Under Trench', _f(kSectionTele, kTeleUnderTrench)),
              _row(
                context,
                'Defense (qualitative)',
                _f(kSectionTele, kTeleDefense),
              ),
              _row(context, 'E-Stop', _f(kSectionTele, kTeleEStop)),
              _row(context, 'Lost Comms', _f(kSectionTele, kTeleLostComms)),
            ],
          ),
          _phaseSection(
            context,
            header: const ScoutingSubHeader(
              title: 'Endgame',
              icon: Symbols.flag_rounded,
            ),
            rows: [
              _row(context, 'Climb Level', _f(kSectionEndgame, kEndClimb)),
              _row(
                context,
                'Climb Position',
                _f(kSectionEndgame, kEndClimbLocation),
              ),
              _row(
                context,
                'Defense On Shift',
                _f(kSectionEndgame, kEndPlayedDefenseOnShift),
              ),
              _row(
                context,
                'Defense Off Shift',
                _f(kSectionEndgame, kEndPlayedDefenseOffShift),
              ),
              _row(context, 'Fouls', _f(kSectionEndgame, kEndFouls)),
              _row(context, 'Scout Notes', _f(kSectionEndgame, kEndNotes)),
              // TODO(strat): add strat fields once strat data is implemented.
            ],
          ),
        ],
      ),
    );
  }
}
