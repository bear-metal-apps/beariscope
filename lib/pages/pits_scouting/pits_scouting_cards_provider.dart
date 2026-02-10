import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoutedNotifier extends Notifier<List<bool>> {
  @override
  List<bool> build() {
    return List.filled(29, false);
    // Once this is hooked up to TBA, here are the things that need to change:
    // 29  ->  tBATeams.length
    // In pits_scouting_home_page:
    // for (int i = 1; i <= scoutedNotifierProvider.length; i++) {
    //   teams.add(
    //     PitsScoutingTeamCard(
    //       team: { "teamNumber": $i },
    //       scouted: ref.read(scoutedNotifierProvider.notifier).searchTeam(i);,
    //     )
    //   );
    // }
    // cardID will also be synonymous with teamNumber btw on pits_scouting_assets.dart
  }

  void addInstance(bool value) {
    state = [...state, value];
  }

  void replaceValue(int index) {
    if (index < 0 || index >= state.length) return;

        {
      final newList = [...state];
      newList[index] = true;
      state = newList;
    }
  }

  bool searchTeam(int index) {
    final List<bool> tempList = [...state];

    return tempList[index];
  }
}

final scoutedNotifierProvider =
NotifierProvider<ScoutedNotifier, List<bool>>(ScoutedNotifier.new);
