import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class TeamService {
  final Client client;
  final Teams teams;

  /// Creates a new TeamService instance with the provided Appwrite client.
  ///
  /// This service handles all team-related API operations including creating,
  /// retrieving, updating, and deleting teams.
  ///
  /// Parameters:
  ///   - client: The Appwrite client instance used for API communication
  TeamService({required this.client}) : teams = Teams(client);

  /// Creates a new team with the specified name and number.
  ///
  /// This method creates a team in the Appwrite backend and stores additional
  /// team information (name and number) in the team preferences. The team creator
  /// is automatically assigned the specified roles.
  ///
  /// Parameters:
  ///   - teamName: The display name for the team
  ///   - teamNumber: The team's official number (e.g., FRC team number)
  ///   - roles: List of roles to assign to the creator, defaults to ['owner']
  ///
  /// Returns:
  ///   The newly created Team object with all properties
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

  /// Retrieves a team by its unique identifier.
  ///
  /// This method fetches the complete team information from the Appwrite backend.
  ///
  /// Parameters:
  ///   - teamId: The unique identifier of the team to retrieve
  ///
  /// Returns:
  ///   The Team object with all its properties
  Future<models.Team> getTeam(String teamId) async {
    return await teams.get(teamId: teamId);
  }

  /// Retrieves the current user's team.
  ///
  /// This method fetches the first team associated with the current user.
  /// The application assumes users belong to only one team at a time.
  ///
  /// Returns:
  ///   The Team object representing the user's current team
  ///
  /// Throws:
  ///   Exception if the user doesn't belong to any team
  Future<models.Team> getCurrentTeam() async {
    final teamsList = await teams.list();
    if (teamsList.teams.isNotEmpty) {
      return teamsList.teams.first;
    } else {
      throw Exception('No teams found for current user');
    }
  }

  /// Retrieves the ID of the currently authenticated user.
  ///
  /// This method accesses the Appwrite Account API to get the current user's
  /// unique identifier, which is needed for various team operations.
  ///
  /// Returns:
  ///   The unique identifier of the currently authenticated user
  Future<String> getCurrentUserId() async {
    final account = Account(client);
    final user = await account.get();
    return user.$id;
  }

  /// Retrieves all memberships for a specific team.
  ///
  /// This method fetches the complete list of users who are members of the
  /// specified team, along with their roles and membership details.
  ///
  /// Parameters:
  ///   - teamId: The unique identifier of the team
  ///
  /// Returns:
  ///   A MembershipList object containing all team memberships
  Future<models.MembershipList> getMemberships(String teamId) async {
    return await teams.listMemberships(teamId: teamId);
  }

  /// Permanently deletes a team from the system.
  ///
  /// This is a destructive operation that removes the team and all associated
  /// data. This action cannot be undone and will affect all team members.
  ///
  /// Parameters:
  ///   - teamId: The unique identifier of the team to delete
  Future<void> deleteTeam(String teamId) async {
    await teams.delete(teamId: teamId);
  }

  /// Removes a user from a team by deleting their membership.
  ///
  /// This method allows a user to leave a team without deleting the entire team.
  /// Other members will still have access to the team after this operation.
  ///
  /// Parameters:
  ///   - teamId: The unique identifier of the team
  ///   - membershipID: The unique identifier of the membership to remove
  Future<void> leaveTeam(String teamId, membershipID) async {
    await teams.deleteMembership(teamId: teamId, membershipId: membershipID);
  }
}
