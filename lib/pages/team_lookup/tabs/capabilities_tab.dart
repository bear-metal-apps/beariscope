import 'package:beariscope/pages/team_lookup/tabs/scouting_tab_widgets.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class CapabilitiesTab extends ConsumerWidget {
  final int teamNumber;

  const CapabilitiesTab({super.key, required this.teamNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamScoutingProvider(teamNumber));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bundle) => _CapabilitiesBody(bundle: bundle),
    );
  }
}

class _CapabilitiesBody extends StatelessWidget {
  final TeamScoutingBundle bundle;

  const _CapabilitiesBody({required this.bundle});

  @override
  Widget build(BuildContext context) {
    if (!bundle.hasPitsData && !bundle.hasMatchData) {
      return const Center(
        child: Text('No scouting data recorded for this team.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ScoutingSectionHeader(
          title: 'Hardware',
          icon: Symbols.build_rounded,
        ),
        const SizedBox(height: kScoutingHeaderGap),
        _hardwareCard(context),
        const SizedBox(height: kScoutingSectionGap),
        const ScoutingSectionHeader(
          title: 'Shooter / Collector / Range',
          icon: Symbols.adjust_rounded,
        ),
        const SizedBox(height: kScoutingHeaderGap),
        _shooterCollectorCard(context),
        const SizedBox(height: kScoutingSectionGap),
        const ScoutingSectionHeader(
          title: 'Climb',
          icon: Symbols.moving_rounded,
        ),
        const SizedBox(height: kScoutingHeaderGap),
        _climbCard(context),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Hardware card
  // ---------------------------------------------------------------------------

  Widget _hardwareCard(BuildContext context) {
    final drivetrainType = bundle.getPitsField<String>('drivetrainType') ?? '—';
    final swerveBrand = bundle.getPitsField<String>('swerveBrand');
    final swerveGearRatio = bundle.getPitsField<String>('swerveGearRatio');
    final motorType = bundle.getPitsField<String>('motorType') ?? '—';
    final wheelType = bundle.getPitsField<String>('wheelType') ?? '—';
    final weight = bundle.getPitsDouble('weight');
    final chassisLength = bundle.getPitsDouble('chassisLength');
    final chassisWidth = bundle.getPitsDouble('chassisWidth');
    final chassisHeight = bundle.getPitsDouble('chassisHeight');
    final hExt = bundle.getPitsDouble('horizontalExtensionLimit');
    final vExt = bundle.getPitsDouble('verticalExtensionLimit');
    final hopperSize = bundle.getPitsField<int>('hopperSize') as num?;
    final pathwayPref = bundle.getPitsField<String>('pathwayPreference') ?? '—';

    final showSwerve = drivetrainType == 'Swerve';

    return _specsCard(
      context,
      rows: [
        ScoutingDataRow(label: 'Drivetrain', value: drivetrainType),
        if (showSwerve && swerveBrand != null)
          ScoutingDataRow(label: '  Swerve Brand', value: swerveBrand),
        if (showSwerve && swerveGearRatio != null && swerveGearRatio.isNotEmpty)
          ScoutingDataRow(label: '  Gear Ratio', value: swerveGearRatio),
        ScoutingDataRow(label: 'Drive Motor', value: motorType),
        ScoutingDataRow(label: 'Wheel Type', value: wheelType),
        ScoutingDataRow(
          label: 'Chassis (L × W × H)',
          value:
              [
                    chassisLength,
                    chassisWidth,
                    chassisHeight,
                  ].every((v) => v != null)
                  ? '${chassisLength!.toStringAsFixed(1)}" × ${chassisWidth!.toStringAsFixed(1)}" × ${chassisHeight!.toStringAsFixed(1)}"'
                  : '—',
        ),
        ScoutingDataRow(
          label: 'Weight',
          value: weight != null ? '${weight.toStringAsFixed(1)} lbs' : '—',
        ),
        ScoutingDataRow(
          label: 'Extension (H / V)',
          value:
              '${hExt != null ? '${hExt.toStringAsFixed(1)}"' : '—'} / ${vExt != null ? '${vExt.toStringAsFixed(1)}"' : '—'}',
        ),
        ScoutingDataRow(
          label: 'Hopper Size',
          value: hopperSize != null ? '${hopperSize.toInt()} balls' : '—',
        ),
        ScoutingDataRow(label: 'Pathway Preference', value: pathwayPref),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shooter / Collector / Range card
  // ---------------------------------------------------------------------------

  Widget _shooterCollectorCard(BuildContext context) {
    final shooterType = bundle.getPitsField<String>('shooter') ?? '—';
    final collectorType = bundle.getPitsField<String>('collectorType') ?? '—';
    final indexerType = bundle.getPitsField<String>('indexerType') ?? '—';
    final powered = bundle.getPitsField<String>('powered') ?? '—';
    final outtakeRate = bundle.getPitsDouble('fuelOuttakeRate');
    final pitsAccuracy = bundle.getPitsDouble('averageAccuracy');
    final trenchCapability =
        bundle.getPitsField<String>('trenchCapability') ?? '—';
    final rangeFromField = bundle.getPitsListField('rangeFromField');
    final moveWhileShooting = bundle.getPitsListField('moveWhileShooting');
    final collectionLocations = bundle.getPitsListField(
      'fuelCollectionLocation',
    );

    // Actual accuracy from match data (tele, since that's where most shots are).
    final actualTeleAccuracy = bundle.avgMatchField(
      kSectionTele,
      kTeleFuelAccuracy,
    );
    final actualAutoAccuracy = bundle.avgMatchField(
      kSectionAuto,
      kAutoFuelAccuracy,
    );
    final hasMatchData = bundle.hasMatchData;

    return _specsCard(
      context,
      rows: [
        ScoutingDataRow(label: 'Shooter Type', value: shooterType),
        ScoutingDataRow(label: 'Collector Type', value: collectorType),
        ScoutingDataRow(label: 'Indexer Type', value: indexerType),
        ScoutingDataRow(label: 'Powered Indexer', value: powered),
        ScoutingDataRow(
          label: 'Outtake Rate',
          value:
              outtakeRate != null
                  ? '${outtakeRate.toStringAsFixed(1)} balls/s'
                  : '—',
        ),
        const ScoutingDataDivider(),
        ScoutingDataRow(
          label: 'Claimed Accuracy (Pits)',
          value:
              pitsAccuracy != null
                  ? '${pitsAccuracy.toStringAsFixed(1)}%'
                  : '—',
        ),
        if (hasMatchData) ...[
          ScoutingDataRow(
            label: 'Actual Auto Accuracy (Avg)',
            value: '${actualAutoAccuracy.toStringAsFixed(1)}%',
            highlight: true,
          ),
          ScoutingDataRow(
            label: 'Actual Tele Accuracy (Avg)',
            value: '${actualTeleAccuracy.toStringAsFixed(1)}%',
            highlight: true,
          ),
        ],
        const ScoutingDataDivider(),
        ScoutingDataRow(label: 'Trench Capable', value: trenchCapability),
        ScoutingDataRow(
          label: 'Mobile Shooting',
          value:
              moveWhileShooting.isNotEmpty ? moveWhileShooting.join(', ') : '—',
        ),
        ScoutingDataRow(
          label: 'Range from Field',
          value: rangeFromField.isNotEmpty ? rangeFromField.join(' · ') : '—',
        ),
        ScoutingDataRow(
          label: 'Fuel Collection Spots',
          value:
              collectionLocations.isNotEmpty
                  ? collectionLocations.join(', ')
                  : '—',
        ),
        // TODO(strat): add susceptibility to defense from strat data.
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Climb card
  // ---------------------------------------------------------------------------

  Widget _climbCard(BuildContext context) {
    final climbMethod = bundle.getPitsField<String>('climbMethod') ?? '—';
    final climbTypes = bundle.getPitsListField('climbType');
    final climbLevels = bundle.getPitsListField('climbLevel');
    final climbConsistency = bundle.getPitsDouble('climbConsistency');
    final autoClimb = bundle.getPitsField<String>('autoClimb') ?? '—';

    // Derive actual endgame climb stats from match data.
    final n = bundle.matchDocs.length;
    final hasMatchData = bundle.hasMatchData;
    final actualClimbRate =
        hasMatchData
            ? bundle.rateMatchField(
              kSectionEndgame,
              kEndClimb,
              (v) => v != null && v.toString().isNotEmpty,
            )
            : null;
    final climbCounts = <String, int>{};
    if (hasMatchData) {
      for (final doc in bundle.matchDocs) {
        final v =
            TeamScoutingBundle.getMatchField(
              doc,
              kSectionEndgame,
              kEndClimb,
            )?.toString();
        if (v != null && v.isNotEmpty)
          climbCounts[v] = (climbCounts[v] ?? 0) + 1;
      }
    }

    final autoL1Rate =
        hasMatchData
            ? bundle.rateMatchField(
              kSectionAuto,
              kAutoClimbL1,
              (v) => v == 'Successful',
            )
            : null;

    return _specsCard(
      context,
      rows: [
        ScoutingDataRow(label: 'Mechanism', value: climbMethod),
        ScoutingDataRow(
          label: 'Climb Types',
          value: climbTypes.isNotEmpty ? climbTypes.join(', ') : '—',
        ),
        ScoutingDataRow(
          label: 'Claimed Levels',
          value: climbLevels.isNotEmpty ? climbLevels.join(', ') : '—',
        ),
        ScoutingDataRow(
          label: 'Claimed Consistency',
          value:
              climbConsistency != null
                  ? '${climbConsistency.toStringAsFixed(1)} / 10'
                  : '—',
        ),
        ScoutingDataRow(label: 'Auto Climb', value: autoClimb),
        if (hasMatchData) ...[
          const ScoutingDataDivider(),
          ScoutingDataRow(
            label: 'Actual Endgame Climb Rate',
            value:
                actualClimbRate != null
                    ? '${(actualClimbRate * 100).toStringAsFixed(1)}% ($n matches)'
                    : '—',
            highlight: true,
          ),
          if (climbCounts.isNotEmpty)
            ScoutingDataRow(
              label: 'Level Breakdown',
              value: climbCounts.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(' · '),
              highlight: true,
            ),
          ScoutingDataRow(
            label: 'Actual Auto L1 Rate',
            value:
                autoL1Rate != null
                    ? '${(autoL1Rate * 100).toStringAsFixed(1)}%'
                    : '—',
            highlight: true,
          ),
        ],
        // TODO(strat): add mechanical soundness from strat data.
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared widget helpers
  // ---------------------------------------------------------------------------

  Widget _specsCard(BuildContext context, {required List<Widget> rows}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }
}
