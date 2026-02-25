class ScoutingDocument {
  final String id;
  final String uploadBatchId;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool processed;

  const ScoutingDocument({
    required this.id,
    required this.uploadBatchId,
    required this.timestamp,
    required this.data,
    required this.processed,
  });

  Map<String, dynamic>? get meta {
    final m = data['meta'];
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  factory ScoutingDocument.fromJson(Map<String, dynamic> json) {
    return ScoutingDocument(
      id: json['_id']?.toString() ?? '',
      uploadBatchId: json['uploadBatchId']?.toString() ?? '',
      timestamp: _parseTimestamp(json['timestamp']),
      data:
          json['data'] is Map
              ? Map<String, dynamic>.from(json['data'] as Map)
              : const {},
      processed: json['processed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'uploadBatchId': uploadBatchId,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'processed': processed,
  };

  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime(0);
    if (value is Map) {
      final date = value[r'$date'];
      if (date is String) return DateTime.tryParse(date) ?? DateTime(0);
    }
    return DateTime(0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoutingDocument &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
