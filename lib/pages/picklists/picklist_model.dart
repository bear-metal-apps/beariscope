import 'package:flutter_riverpod/flutter_riverpod.dart';

class Picklist {
  String id;
  String name;
  String password;
  String eventKey;
  String eventName;
  List<Map<String, dynamic>> teams;
  String createdAt;

  Picklist({
    required this.id,
    required this.name,
    required this.password,
    required this.eventKey,
    required this.eventName,
    required this.teams,
    required this.createdAt,
  });

  // convert to/from map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'eventKey': eventKey,
      'eventName': eventName,
      'teams': teams,
      'createdAt': createdAt,
    };
  }

  factory Picklist.fromMap(Map<String, dynamic> map) {
    return Picklist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      eventKey: map['eventKey'] ?? '',
      eventName: map['eventName'] ?? '',
      teams: List<Map<String, dynamic>>.from(
        (map['teams'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
      ),
      createdAt: map['createdAt'] ?? '',
    );
  }
}

class PicklistNotifier extends Notifier<List<Picklist>> {
  @override
  List<Picklist> build() {
    return [];
  }

  void addPicklist(Picklist picklist) {
    state = [...state, picklist];
  }

  void removePicklist(Picklist picklist) {
    state = state.where((p) => p.id != picklist.id).toList();
  }

  void updatePicklist(Picklist oldPicklist, Picklist newPicklist) {
    // find and remove the old picklist by password
    for (int i = 0; i < state.length; i++) {
      if (state[i].password == oldPicklist.password) {
        final updated = [...state];
        updated.removeAt(i);
        updated.add(newPicklist);
        state = updated;
        return;
      }
    }
    // if not found, just add the new one
    addPicklist(newPicklist);
  }
}

final picklistProvider = NotifierProvider<PicklistNotifier, List<Picklist>>(
  () => PicklistNotifier(),
);
