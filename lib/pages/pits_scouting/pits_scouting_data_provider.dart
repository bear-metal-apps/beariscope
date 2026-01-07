import 'package:riverpod/riverpod.dart';

class PitsScoutingDatabase extends Notifier<List<PitsScoutingTeamData>> {
  @override
  List<PitsScoutingTeamData> build() => [];

  void editData(PitsScoutingTeamData data) => state = [...state, data];

  void removeUser(PitsScoutingTeamData data) => state = state.where(
          (e) => e.scouted != data.scouted
  ).toList();
}

final PitsScoutingDatabaseProvider =
NotifierProvider<PitsScoutingDatabase, List<PitsScoutingTeamData>>(
  PitsScoutingDatabase.new,
);

class PitsScoutingTeamData {
  String teamName;
  int teamNumber;
  bool scouted;
  String notes;

  PitsScoutingTeamData(this.teamName, this.teamNumber, this.scouted, this.notes);
}