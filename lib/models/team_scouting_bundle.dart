import 'package:beariscope/models/scouting_document.dart';

/// Aggregated scouting data for a single team, bundled from all relevant
/// data sources (match, pits, strat).
///
/// Match documents come from the most recent event that has match data for
/// this team.  Pits data falls back to the most recent event that has a pits
/// entry, which may differ from the match event.
class TeamScoutingBundle {
  /// All match scouting documents for this team's most recent event.
  final List<ScoutingDocument> matchDocs;

  /// Most recent pits scouting document, potentially from a different (older)
  /// event than [matchDocs] if the current event has no pits entry yet.
  final ScoutingDocument? pitsDoc;

  /// Strat scouting document.
  // TODO(strat): wire strat data when strat upload is implemented.
  final ScoutingDocument? stratDoc;

  const TeamScoutingBundle({
    required this.matchDocs,
    required this.pitsDoc,
    required this.stratDoc,
  });

  bool get hasMatchData => matchDocs.isNotEmpty;
  bool get hasPitsData => pitsDoc != null;

  // TODO(strat): update once strat data is implemented.
  bool get hasStratData => stratDoc != null;

  // ---------------------------------------------------------------------------
  // Static field accessor – match documents
  // ---------------------------------------------------------------------------

  /// Returns the value of [fieldId] inside [sectionId] for a single [doc].
  ///
  /// Match data is stored as:
  /// ```json
  /// { "sections": [ { "sectionId": "auto", "fields": { "fuel_scored": 3 } } ] }
  /// ```
  static dynamic getMatchField(
    ScoutingDocument doc,
    String sectionId,
    String fieldId,
  ) {
    final sections = doc.data['sections'];
    if (sections is! List) return null;
    for (final section in sections) {
      if (section is! Map) continue;
      if (section['sectionId']?.toString() != sectionId) continue;
      final fields = section['fields'];
      if (fields is Map) return fields[fieldId];
      return null;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Aggregate helpers over all matchDocs
  // ---------------------------------------------------------------------------

  /// Numeric average of [fieldId] in [sectionId] across all [matchDocs].
  /// Returns 0.0 when no docs contain the field.
  double avgMatchField(String sectionId, String fieldId) {
    if (matchDocs.isEmpty) return 0.0;
    double sum = 0;
    int count = 0;
    for (final doc in matchDocs) {
      final val = getMatchField(doc, sectionId, fieldId);
      if (val is num) {
        sum += val.toDouble();
        count++;
      }
    }
    return count == 0 ? 0.0 : sum / count;
  }

  /// Sum of [fieldId] in [sectionId] across all [matchDocs].
  double sumMatchField(String sectionId, String fieldId) {
    if (matchDocs.isEmpty) return 0.0;
    double sum = 0;
    for (final doc in matchDocs) {
      final val = getMatchField(doc, sectionId, fieldId);
      if (val is num) sum += val.toDouble();
    }
    return sum;
  }

  /// Number of matches where [fieldId] in [sectionId] satisfies [test].
  int countMatchField(
    String sectionId,
    String fieldId,
    bool Function(dynamic) test,
  ) {
    return matchDocs
        .where((doc) => test(getMatchField(doc, sectionId, fieldId)))
        .length;
  }

  /// Rate (0.0–1.0) of matches where [fieldId] in [sectionId] satisfies [test].
  /// Returns 0.0 for empty match lists.
  double rateMatchField(
    String sectionId,
    String fieldId,
    bool Function(dynamic) test,
  ) {
    if (matchDocs.isEmpty) return 0.0;
    return countMatchField(sectionId, fieldId, test) / matchDocs.length;
  }

  /// Most common string value of [fieldId] in [sectionId] across [matchDocs].
  String? modalMatchField(String sectionId, String fieldId) {
    if (matchDocs.isEmpty) return null;
    final counts = <String, int>{};
    for (final doc in matchDocs) {
      final val = getMatchField(doc, sectionId, fieldId)?.toString();
      if (val != null && val.isNotEmpty) {
        counts[val] = (counts[val] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Boolean rate: fraction of matches where the field is `true`.
  double boolRateMatchField(String sectionId, String fieldId) =>
      rateMatchField(sectionId, fieldId, (v) => v == true);

  // ---------------------------------------------------------------------------
  // Pits field accessors
  // ---------------------------------------------------------------------------

  /// Returns [pitsDoc.data[key]] cast to [T], or null if absent or wrong type.
  T? getPitsField<T>(String key) {
    final val = pitsDoc?.data[key];
    if (val is T) return val;
    return null;
  }

  /// Returns a pits list field as `List<String>`, or empty list if absent.
  List<String> getPitsListField(String key) {
    final val = pitsDoc?.data[key];
    if (val is List) return val.map((e) => e.toString()).toList();
    return [];
  }

  /// Returns a numeric pits field coerced to double, or null.
  double? getPitsDouble(String key) {
    final val = pitsDoc?.data[key];
    if (val is num) return val.toDouble();
    return null;
  }

  // ---------------------------------------------------------------------------
  // Strat field accessors
  // ---------------------------------------------------------------------------

  // TODO(strat): add strat field accessors once strat data schema is defined.

  /// Driver skill rating (1–10). Returns null until strat data is available.
  // TODO(strat): return stratDoc?.data['driverSkill']
  int? get stratDriverSkill => null;

  /// Defense rating (1–10). Returns null until strat data is available.
  // TODO(strat): return stratDoc?.data['defenseRating']
  int? get stratDefenseRating => null;

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  /// Match number from a document, if the field is present.
  /// pawfinder will expose this as `data['matchNumber']` in a future update.
  static int? matchNumber(ScoutingDocument doc) {
    final mn = doc.data['matchNumber'];
    if (mn is int) return mn;
    if (mn is double) return mn.toInt();
    if (mn is String) return int.tryParse(mn);
    return null;
  }

  /// Team number from a document, normalised to int.
  static int? teamNumber(ScoutingDocument doc) {
    final tn = doc.data['teamNumber'];
    if (tn is int) return tn;
    if (tn is double) return tn.toInt();
    if (tn is String) return int.tryParse(tn);
    return null;
  }
}
