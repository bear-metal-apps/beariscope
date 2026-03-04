import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns a [TeamScoutingBundle] for the given [teamNumber].
///
/// All documents come from the current event only — [scoutingDataProvider]
/// is already filtered to the current event before this provider runs.
///
/// Strat docs are matched by team number appearing in any of the four ranking
/// lists (not via a top-level teamNumber field).
final teamScoutingProvider = FutureProvider.family<TeamScoutingBundle, int>((
  ref,
  teamNumber,
) async {
  final allDocs = await ref.watch(scoutingDataProvider.future);

  // Filter to docs belonging to this team.
  // pawfinder writes teamNumber alongside the meta object as data['teamNumber'].
  final teamDocs =
      allDocs.where((doc) {
        return TeamScoutingBundle.teamNumber(doc) == teamNumber;
      }).toList();

  final matchDocs =
      teamDocs
          .where((doc) => doc.meta?['type']?.toString() == 'match')
          .toList();

  final pitsDocs =
      teamDocs.where((doc) => doc.meta?['type']?.toString() == 'pits').toList();

  // Take the most recently uploaded pits doc for this team (if any).
  pitsDocs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  final pitsDoc = pitsDocs.firstOrNull;

  final driveTeamDocs =
      teamDocs
          .where((doc) => doc.meta?['type']?.toString() == 'drive_team')
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  // Strat docs are keyed by team number inside ranking lists, not by a top-level
  // teamNumber field.  Search all event docs for strat entries that include this
  // team in any of the four ranking lists.
  const stratRankingKeys = [
    'driverSkillRanking',
    'defensiveSkillRanking',
    'defensiveSusceptibilityRanking',
    'mechanicalStabilityRanking',
  ];
  final teamStr = teamNumber.toString();
  final stratDocs =
      allDocs.where((doc) {
          if (doc.meta?['type']?.toString() != 'strat') return false;
          return stratRankingKeys.any((key) {
            final v = doc.data[key];
            return v is List && v.map((e) => e.toString()).contains(teamStr);
          });
        }).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  return TeamScoutingBundle(
    matchDocs: matchDocs,
    pitsDoc: pitsDoc,
    stratDocs: stratDocs,
    driveTeamDocs: driveTeamDocs,
  );
});
