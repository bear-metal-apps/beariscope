import 'dart:math';

import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kRankingKeys = [
  'driverSkillRanking',
  'defensiveSkillRanking',
  'defensiveSusceptibilityRanking',
  'mechanicalStabilityRanking',
];

// thank you misha for all this math i dont understand any of it
class StratZScoreData {
  final Map<int, double> driverSkillZ;
  final Map<int, double> defensiveSkillZ;
  final Map<int, double> defensiveSusceptibilityZ;
  final Map<int, double> mechanicalStabilityZ;

  const StratZScoreData({
    required this.driverSkillZ,
    required this.defensiveSkillZ,
    required this.defensiveSusceptibilityZ,
    required this.mechanicalStabilityZ,
  });

  static const empty = StratZScoreData(
    driverSkillZ: {},
    defensiveSkillZ: {},
    defensiveSusceptibilityZ: {},
    mechanicalStabilityZ: {},
  );

  Map<int, double> zForKey(String key) {
    switch (key) {
      case 'driverSkillRanking':
        return driverSkillZ;
      case 'defensiveSkillRanking':
        return defensiveSkillZ;
      case 'defensiveSusceptibilityRanking':
        return defensiveSusceptibilityZ;
      case 'mechanicalStabilityRanking':
        return mechanicalStabilityZ;
      default:
        return {};
    }
  }

  static String zLabel(double? z) {
    if (z == null) return '—';
    final sign = z >= 0 ? '+' : '\u2212';
    return '$sign${z.abs().toStringAsFixed(2)}\u03c3'; // sigma male
  }
}

Map<int, double> _sdScorer(Map<int, double> teamAverages) {
  if (teamAverages.isEmpty) return {};
  final values = teamAverages.values.toList();
  final mean = values.fold(0.0, (a, b) => a + b) / values.length;
  final variance =
      values.fold(0.0, (a, b) => a + pow(b - mean, 2)) / values.length;
  final sd = sqrt(variance);
  return teamAverages.map((team, avg) {
    if (sd == 0 || sd.isNaN || sd.isInfinite) return MapEntry(team, 0.0);
    final z = (avg - mean) / sd;
    return MapEntry(team, (z.isNaN || z.isInfinite) ? 0.0 : z);
  });
}

StratZScoreData _computeStratZScores(List<ScoutingDocument> stratDocs) {
  final rawScores = <String, Map<int, List<double>>>{
    for (final k in _kRankingKeys) k: {},
  };

  for (final doc in stratDocs) {
    for (final key in _kRankingKeys) {
      final list = doc.data[key];
      if (list is! List) continue;
      final n = list.length;
      for (int i = 0; i < n; i++) {
        final team = int.tryParse(list[i]?.toString() ?? '');
        if (team == null) continue;
        rawScores[key]!.putIfAbsent(team, () => []).add((n - i).toDouble());
      }
    }
  }

  Map<int, double> zFor(String key) {
    final perTeam = rawScores[key]!;
    if (perTeam.isEmpty) return {};
    final averages = perTeam.map(
      (team, scores) =>
          MapEntry(team, scores.fold(0.0, (a, b) => a + b) / scores.length),
    );
    return _sdScorer(averages);
  }

  return StratZScoreData(
    driverSkillZ: zFor('driverSkillRanking'),
    defensiveSkillZ: zFor('defensiveSkillRanking'),
    defensiveSusceptibilityZ: zFor('defensiveSusceptibilityRanking'),
    mechanicalStabilityZ: zFor('mechanicalStabilityRanking'),
  );
}

final stratZScoresProvider = FutureProvider<StratZScoreData>((ref) async {
  final allDocs = await ref.watch(scoutingDataProvider.future);
  final stratDocs =
      allDocs.where((doc) => doc.meta?['type']?.toString() == 'strat').toList();
  if (stratDocs.isEmpty) return StratZScoreData.empty;
  return _computeStratZScores(stratDocs);
});
