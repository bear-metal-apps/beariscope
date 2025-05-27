import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;

class TeamService {
  final Client client;
  final Teams teams;
  final Functions functions;

  TeamService({required this.client})
    : teams = Teams(client),
      functions = Functions(client);

  Future<models.Team> createTeam({
    required String teamName,
    required int teamNumber,
    List<String> roles = const ['owner'],
  }) async {
    final String id = ID.unique();

    await teams.create(teamId: id, name: teamNumber.toString(), roles: roles);
    await teams.updatePrefs(
      teamId: id,
      prefs: {'teamName': teamName, 'teamNumber': teamNumber},
    );
    return await teams.get(teamId: id);
  }

  Future<models.Team> getTeam(String teamId) async {
    return await teams.get(teamId: teamId);
  }

  Future<models.Team> getCurrentTeam() async {
    final teamsList = await teams.list();
    if (teamsList.teams.isNotEmpty) {
      return teamsList.teams.first;
    } else {
      throw Exception('No teams found for current user');
    }
  }

  Future<String> getCurrentUserId() async {
    final account = Account(client);
    final user = await account.get();
    return user.$id;
  }

  Future<models.MembershipList> getMemberships(String teamId) async {
    return await teams.listMemberships(teamId: teamId);
  }

  Future<void> deleteTeam(String teamId) async {
    await teams.delete(teamId: teamId);
  }

  Future<void> leaveTeam(String teamId, membershipID) async {
    await teams.deleteMembership(teamId: teamId, membershipId: membershipID);
  }

  Future<String> createJoinCode(String teamId) async {
    final execution = await functions.createExecution(
      functionId: '682ead86000333ab4057',
      path: '/create_join_code',
      method: ExecutionMethod.pOST,
      body: jsonEncode({'teamId': teamId}),
    );
    final Map<String, dynamic> responseBody = jsonDecode(
      execution.responseBody,
    );
    if (execution.responseStatusCode != 200) {
      throw Exception(
        'Failed to create join code: ${responseBody['error'] ?? 'Unknown error'}',
      );
    }
    return responseBody['joinCode'];
  }

  Future<void> useJoinCode(String joinCode) async {
    final execution = await functions.createExecution(
      functionId: '682ead86000333ab4057',
      path: '/use_join_code',
      method: ExecutionMethod.pOST,
      body: jsonEncode({'joinCode': joinCode}),
    );
    final Map<String, dynamic> responseBody = jsonDecode(
      execution.responseBody,
    );
    if (execution.responseStatusCode != 200) {
      throw Exception(
        'Failed to use join code: ${responseBody['error'] ?? 'Unknown error'}',
      );
    }
  }
}
