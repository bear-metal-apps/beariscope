import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns a [TeamScoutingBundle] for the given [teamNumber].
///
/// All documents come from the current event only — [scoutingDataProvider]
/// is already filtered to the current event before this provider runs.
///
/// Strat data is not yet implemented — [TeamScoutingBundle.stratDoc] is always
/// null until strat upload is wired up.
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

  return TeamScoutingBundle(
    matchDocs: matchDocs,
    pitsDoc: pitsDoc,
    // TODO(strat): pass strat doc once strat upload is implemented.
    stratDoc: null,
  );
});
