import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class TeamService {
  final Client client;
  final Teams teams;

  TeamService({required this.client}) : teams = Teams(client);

  // Create a new team with the team name and number included in the prefs
  // Roles are customizable but probably don't need to be changed
  Future<models.Team> createTeam({
    required String teamName,
    required int teamNumber,
    List<String> roles = const ['owner', 'lead', 'scout'],
  }) async {
    final String id = ID.unique();

    await teams.create(teamId: id, name: teamNumber.toString(), roles: roles);
    await teams.updatePrefs(
      teamId: id,
      prefs: {'teamName': teamName, 'teamNumber': teamNumber},
    );
    return await teams.get(teamId: id);
  }

  // Get a team by it's ID
  Future<models.Team> getTeam(String teamId) async {
    return await teams.get(teamId: teamId);
  }

  // Get the user's current team (technically the first team they're on but there should only ever be one)
  Future<models.Team> getCurrentTeam() async {
    final teamsList = await teams.list();
    if (teamsList.teams.isNotEmpty) {
      return teamsList.teams.first;
    } else {
      throw Exception('No teams found for current user');
    }
  }

  // Scary!
  Future<void> deleteTeam(String teamId) async {
    await teams.delete(teamId: teamId);
  }
}
