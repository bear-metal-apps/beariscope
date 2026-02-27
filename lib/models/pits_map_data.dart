import 'dart:math' as math;

class MapPoint {
  final double x;
  final double y;

  const MapPoint(this.x, this.y);

  factory MapPoint.fromJson(Map<String, dynamic> json) {
    return MapPoint(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }
}

class MapComponentBase {
  final MapPoint position;
  final MapPoint size;

  final double? angle;

  const MapComponentBase({
    required this.position,
    required this.size,
    this.angle,
  });

  double get angleRadians => (angle ?? 0.0) * math.pi / 180.0;

  static MapComponentBase fromJson(Map<String, dynamic> json) {
    return MapComponentBase(
      position: MapPoint.fromJson(json['position'] as Map<String, dynamic>),
      size: MapPoint.fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num?)?.toDouble(),
    );
  }
}

class PitEntry extends MapComponentBase {
  final String? teamKey;

  const PitEntry({
    required super.position,
    required super.size,
    super.angle,
    this.teamKey,
  });

  int? get teamNumber {
    if (teamKey == null) return null;
    final stripped = teamKey!.toLowerCase().replaceFirst(RegExp(r'^frc'), '');
    return int.tryParse(stripped);
  }

  factory PitEntry.fromJson(Map<String, dynamic> json) {
    return PitEntry(
      position: MapPoint.fromJson(json['position'] as Map<String, dynamic>),
      size: MapPoint.fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num?)?.toDouble(),
      teamKey: json['team'] as String?,
    );
  }
}

class AreaEntry extends MapComponentBase {
  final String label;

  const AreaEntry({
    required super.position,
    required super.size,
    super.angle,
    required this.label,
  });

  factory AreaEntry.fromJson(Map<String, dynamic> json) {
    return AreaEntry(
      position: MapPoint.fromJson(json['position'] as Map<String, dynamic>),
      size: MapPoint.fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num?)?.toDouble(),
      label: json['label'] as String,
    );
  }
}

class LabelEntry extends MapComponentBase {
  final String label;

  const LabelEntry({
    required super.position,
    required super.size,
    super.angle,
    required this.label,
  });

  factory LabelEntry.fromJson(Map<String, dynamic> json) {
    return LabelEntry(
      position: MapPoint.fromJson(json['position'] as Map<String, dynamic>),
      size: MapPoint.fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num?)?.toDouble(),
      label: json['label'] as String,
    );
  }
}

class ArrowEntry extends MapComponentBase {
  final String type;

  const ArrowEntry({
    required super.position,
    required super.size,
    super.angle,
    required this.type,
  });

  factory ArrowEntry.fromJson(Map<String, dynamic> json) {
    return ArrowEntry(
      position: MapPoint.fromJson(json['position'] as Map<String, dynamic>),
      size: MapPoint.fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num?)?.toDouble(),
      type: json['type'] as String,
    );
  }
}

class WallEntry extends MapComponentBase {
  const WallEntry({required super.position, required super.size, super.angle});

  factory WallEntry.fromJson(Map<String, dynamic> json) {
    return WallEntry(
      position: MapPoint.fromJson(json['position'] as Map<String, dynamic>),
      size: MapPoint.fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num?)?.toDouble(),
    );
  }
}

class PitsMapData {
  final String event;
  final MapPoint mapSize;
  final Map<String, PitEntry> pits;
  final Map<String, AreaEntry> areas;
  final Map<String, LabelEntry> labels;
  final Map<String, ArrowEntry> arrows;
  final Map<String, WallEntry> walls;

  final Map<String, String> addresses;

  const PitsMapData({
    required this.event,
    required this.mapSize,
    required this.pits,
    required this.areas,
    required this.labels,
    required this.arrows,
    required this.walls,
    required this.addresses,
  });

  factory PitsMapData.fromJson(Map<String, dynamic> json) {
    final mapJson = json['map'] as Map<String, dynamic>;

    Map<String, T> parseEntries<T>(
      Map<String, dynamic>? raw,
      T Function(Map<String, dynamic>) fromJson,
    ) =>
        raw == null
            ? const {}
            : raw.map(
              (key, value) =>
                  MapEntry(key, fromJson(value as Map<String, dynamic>)),
            );

    final addressesRaw = json['addresses'];
    final Map<String, String> addresses;
    if (addressesRaw is Map) {
      addresses = addressesRaw.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    } else {
      addresses = {};
    }

    return PitsMapData(
      event: json['event'] as String? ?? '',
      mapSize: MapPoint.fromJson(mapJson['size'] as Map<String, dynamic>),
      pits: parseEntries(
        mapJson['pits'] as Map<String, dynamic>?,
        PitEntry.fromJson,
      ),
      areas: parseEntries(
        mapJson['areas'] as Map<String, dynamic>?,
        AreaEntry.fromJson,
      ),
      labels: parseEntries(
        mapJson['labels'] as Map<String, dynamic>?,
        LabelEntry.fromJson,
      ),
      arrows: parseEntries(
        mapJson['arrows'] as Map<String, dynamic>?,
        ArrowEntry.fromJson,
      ),
      walls: parseEntries(
        mapJson['walls'] as Map<String, dynamic>?,
        WallEntry.fromJson,
      ),
      addresses: addresses,
    );
  }
}
