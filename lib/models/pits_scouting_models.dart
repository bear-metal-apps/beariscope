import 'package:beariscope/pages/team_lookup/team_model.dart';

enum PitsScoutingFilter { allTeams, notScouted, scouted }

List<Team> parsePitsTeams(List<Map<String, dynamic>> data) {
  return data
      .map((json) => Team.fromJson(json))
      .where((team) => team.number > 0)
      .toList()
    ..sort((a, b) => a.number.compareTo(b.number));
}

List<Team> filterPitsTeams({
  required List<Team> teams,
  required String query,
  required Set<int> scoutedTeamNumbers,
  required PitsScoutingFilter statusFilter,
}) {
  final trimmedQuery = query.trim();
  final queryIsNumber = int.tryParse(trimmedQuery) != null;

  final queryFiltered =
      trimmedQuery.isEmpty
          ? teams
          : teams.where((team) {
            if (queryIsNumber) {
              return team.number.toString().contains(trimmedQuery);
            }
            final normalizedQuery = trimmedQuery.toLowerCase();
            return team.name.toLowerCase().contains(normalizedQuery) ||
                team.key.toLowerCase().contains(normalizedQuery);
          }).toList();

  return queryFiltered.where((team) {
    final isScouted = scoutedTeamNumbers.contains(team.number);
    return switch (statusFilter) {
      PitsScoutingFilter.allTeams => true,
      PitsScoutingFilter.notScouted => !isScouted,
      PitsScoutingFilter.scouted => isScouted,
    };
  }).toList();
}

class PitsScoutingSubmission {
  final String teamName;
  final int teamNumber;
  final int? hopperSize;
  final String motorType;
  final String drivetrainType;
  final String swerveBrand;
  final String swerveGearRatio;
  final String wheelType;
  final double? chassisLength;
  final double? chassisWidth;
  final double? chassisHeight;
  final double? horizontalExtensionLimit;
  final double? verticalExtensionLimit;
  final double? weight;
  final String climbMethod;
  final Set<String> climbType;
  final Set<String> climbLevel;
  final double climbConsistency;
  final String autoClimb;
  final Set<String> fuelCollectionLocation;
  final String pathwayPreference;
  final String trenchCapability;
  final String shooter;
  final int? shooterNumber;
  final String collectorType;
  final double? fuelOuttakeRate;
  final double averageAccuracy;
  final Set<String> moveWhileShooting;
  final Set<String> rangeFromField;
  final String indexerType;
  final String powered;
  final String notes;

  const PitsScoutingSubmission({
    required this.teamName,
    required this.teamNumber,
    required this.hopperSize,
    required this.motorType,
    required this.drivetrainType,
    required this.swerveBrand,
    required this.swerveGearRatio,
    required this.wheelType,
    required this.chassisLength,
    required this.chassisWidth,
    required this.chassisHeight,
    required this.horizontalExtensionLimit,
    required this.verticalExtensionLimit,
    required this.weight,
    required this.climbMethod,
    required this.climbType,
    required this.climbLevel,
    required this.climbConsistency,
    required this.autoClimb,
    required this.fuelCollectionLocation,
    required this.pathwayPreference,
    required this.trenchCapability,
    required this.shooter,
    required this.shooterNumber,
    required this.collectorType,
    required this.fuelOuttakeRate,
    required this.averageAccuracy,
    required this.moveWhileShooting,
    required this.rangeFromField,
    required this.indexerType,
    required this.powered,
    required this.notes,
  });

  Map<String, Object?> toIngestEntry({
    required String eventKey,
    required String scoutedBy,
    int season = 2026,
  }) {
    return {
      'meta': {
        'type': 'pits',
        'version': 1,
        'season': season,
        'event': eventKey,
        'scoutedBy': scoutedBy,
      },
      'teamName': teamName,
      'teamNumber': teamNumber,
      'hopperSize': hopperSize,
      'motorType': motorType,
      'drivetrainType': drivetrainType,
      'swerveBrand': swerveBrand,
      'swerveGearRatio': swerveGearRatio,
      'wheelType': wheelType,
      'chassisLength': chassisLength,
      'chassisWidth': chassisWidth,
      'chassisHeight': chassisHeight,
      'horizontalExtensionLimit': horizontalExtensionLimit,
      'verticalExtensionLimit': verticalExtensionLimit,
      'weight': weight,
      'climbMethod': climbMethod,
      'climbType': climbType.toList(),
      'climbLevel': climbLevel.toList(),
      'climbConsistency': climbConsistency,
      'autoClimb': autoClimb,
      'fuelCollectionLocation': fuelCollectionLocation.toList(),
      'pathwayPreference': pathwayPreference,
      'trenchCapability': trenchCapability,
      'shooter': shooter,
      'shooterNumber': shooterNumber,
      'collectorType': collectorType,
      'fuelOuttakeRate': fuelOuttakeRate,
      'averageAccuracy': averageAccuracy,
      'moveWhileShooting': moveWhileShooting.toList(),
      'rangeFromField': rangeFromField.toList(),
      'indexerType': indexerType,
      'powered': powered,
      'notes': notes,
    };
  }
}
