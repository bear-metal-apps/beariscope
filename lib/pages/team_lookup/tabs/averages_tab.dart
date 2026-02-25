import 'package:beariscope/pages/team_lookup/tabs/scouting_tab_widgets.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class AveragesTab extends ConsumerWidget {
  final int teamNumber;

  const AveragesTab({super.key, required this.teamNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamScoutingProvider(teamNumber));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bundle) => _AveragesBody(bundle: bundle),
    );
  }
}

class _AveragesBody extends StatelessWidget {
  final TeamScoutingBundle bundle;

  const _AveragesBody({required this.bundle});

  @override
  Widget build(BuildContext context) {
    if (!bundle.hasMatchData) {
      return const Center(child: Text('No match data recorded for this team.'));
    }

    final n = bundle.matchDocs.length;
    final avgAutoFuel = bundle.avgMatchField(kSectionAuto, kAutoFuelScored);
    final avgAutoAccuracy = bundle.avgMatchField(
      kSectionAuto,
      kAutoFuelAccuracy,
    );
    final autoL1Rate = bundle.rateMatchField(
      kSectionAuto,
      kAutoClimbL1,
      (v) => v == 'Successful',
    );
    final avgTeleFuel = bundle.avgMatchField(kSectionTele, kTeleFuelScored);
    final avgTeleAccuracy = bundle.avgMatchField(
      kSectionTele,
      kTeleFuelAccuracy,
    );
    final avgAutoFuelPassed = bundle.avgMatchField(
      kSectionAuto,
      kAutoFuelPassed,
    );
    final avgTeleFuelPassed = bundle.avgMatchField(
      kSectionTele,
      kTeleFuelPassed,
    );
    final avgTeleFuelPoached = bundle.avgMatchField(
      kSectionTele,
      kTeleFuelPoached,
    );
    final totalAvgFuel = avgAutoFuel + avgTeleFuel;

    final endgameClimbRate = bundle.rateMatchField(
      kSectionEndgame,
      kEndClimb,
      (v) => v != null && v.toString().isNotEmpty,
    );
    final mostCommonClimb =
        bundle.modalMatchField(kSectionEndgame, kEndClimb) ?? '—';
    final defenseRate = bundle.rateMatchField(
      kSectionEndgame,
      kEndPlayedDefenseOnShift,
      (v) => v == true,
    );
    final avgCollecting = bundle.avgMatchField(kSectionTele, kTeleCollecting);
    final avgOverBump = bundle.avgMatchField(kSectionTele, kTeleOverBump);
    final avgUnderTrench = bundle.avgMatchField(kSectionTele, kTeleUnderTrench);
    final avgFullHopper = bundle.avgMatchField(
      kSectionTele,
      kTelePeriodStartedWithFullHopper,
    );
    final avgFouls = bundle.avgMatchField(kSectionEndgame, kEndFouls);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ScoutingSectionHeader(
          title: 'Scoring',
          icon: Symbols.local_fire_department_rounded,
        ),
        const SizedBox(height: kScoutingHeaderGap),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScoutingDataRow(
                  label: 'Total Avg Fuel / Match',
                  value: _fmtDec(totalAvgFuel),
                  highlight: true,
                ),
                const ScoutingDataDivider(),
                ScoutingDataRow(
                  label: 'Auto Avg Fuel',
                  value: _fmtDec(avgAutoFuel),
                ),
                ScoutingDataRow(
                  label: 'Auto Accuracy',
                  value: _fmtPct(avgAutoAccuracy),
                ),
                ScoutingDataRow(
                  label: 'Auto L1 Climb Rate',
                  value: _fmtPct(autoL1Rate * 100),
                ),
                const ScoutingDataDivider(),
                ScoutingDataRow(
                  label: 'Tele Avg Fuel',
                  value: _fmtDec(avgTeleFuel),
                ),
                ScoutingDataRow(
                  label: 'Tele Accuracy',
                  value: _fmtPct(avgTeleAccuracy),
                ),
                ScoutingDataRow(
                  label: 'Avg Fuel Passed (Auto)',
                  value: _fmtDec(avgAutoFuelPassed),
                ),
                ScoutingDataRow(
                  label: 'Avg Fuel Passed (Tele)',
                  value: _fmtDec(avgTeleFuelPassed),
                ),
                ScoutingDataRow(
                  label: 'Avg Fuel Poached',
                  value: _fmtDec(avgTeleFuelPoached),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: kScoutingSectionGap),
        const ScoutingSectionHeader(
          title: 'Behaviour',
          icon: Symbols.settings_rounded,
        ),
        const SizedBox(height: kScoutingHeaderGap),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScoutingDataRow(
                  label: 'Endgame Climb Rate',
                  value: _fmtPct(endgameClimbRate * 100),
                ),
                ScoutingDataRow(
                  label: 'Most Common Climb Level',
                  value: mostCommonClimb,
                ),
                ScoutingDataRow(
                  label: 'Defense Frequency (on shift)',
                  value: _fmtPct(defenseRate * 100),
                ),
                const ScoutingDataDivider(),
                ScoutingDataRow(
                  label: 'Avg Collecting Time',
                  value: '${_fmtDec(avgCollecting)} / 25 s',
                ),
                ScoutingDataRow(
                  label: 'Avg Over-Bump (Tele)',
                  value: _fmtDec(avgOverBump),
                ),
                ScoutingDataRow(
                  label: 'Avg Under-Trench (Tele)',
                  value: _fmtDec(avgUnderTrench),
                ),
                ScoutingDataRow(
                  label: 'Full-Hopper Periods Avg',
                  value: _fmtDec(avgFullHopper),
                ),
                ScoutingDataRow(label: 'Avg Fouls', value: _fmtDec(avgFouls)),
                const ScoutingDataDivider(),
                // TODO(strat): replace with actual strat data once implemented.
                const ScoutingDataRow(label: 'Driver Skill', value: '—'),
                const ScoutingDataRow(label: 'Defense Rating', value: '—'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Based on $n match${n == 1 ? '' : 'es'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static String _fmtDec(double v) => v.toStringAsFixed(1);
  static String _fmtPct(double v) => '${v.toStringAsFixed(1)}%';
}
