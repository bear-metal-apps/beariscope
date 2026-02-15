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
    // extract number (try multiple field names and types)
    dynamic numberRaw = json['team_number'] ?? json['teamNumber'] ?? json['number'];
    int number = 0;
    if (numberRaw is int) {
      number = numberRaw;
    } else if (numberRaw is String) {
      number = int.tryParse(numberRaw) ?? 0;
    }

    // extract key (try multiple names, or generate from number)
    String? keyRaw = (json['team_key'] ?? json['team'] ?? json['key'])?.toString();
    String key = (keyRaw != null && keyRaw.isNotEmpty) ? keyRaw : 'frc$number';

    // extract name
    String name = (json['nickname'] ?? json['team_name'] ?? json['name'] ?? 'Unknown Team').toString();

    return Team(key: key, number: number, name: name);
  }
}


