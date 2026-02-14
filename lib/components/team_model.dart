class Team {
  final String key;
  final int number;
  final String name;

  Team({
    required this.key,
    required this.number,
    required this.name,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    // Map multiple possible field names from Honeycomb / libkoala responses
    final key = (json['team_key'] ?? json['team'] ?? json['key'])?.toString() ?? '';
    final number = (json['team_number'] ?? json['teamNumber'] ?? json['number']) is int
        ? (json['team_number'] ?? json['teamNumber'] ?? json['number']) as int
        : int.tryParse((json['team_number'] ?? json['teamNumber'] ?? json['number'])?.toString() ?? '') ?? 0;
    var name = (json['nickname'] ?? json['team_name'] ?? json['name'])?.toString();
    name ??= 'Unknown Team';

    // If API didn't provide a team_key but we have a number, create one
    final resolvedKey = key.isNotEmpty ? key : (number != 0 ? 'frc$number' : '');

    return Team(
      key: resolvedKey,
      number: number,
      name: name,
    );
  }
}


