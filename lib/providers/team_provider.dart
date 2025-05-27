import 'package:appwrite/models.dart' as models;
import 'package:beariscope/services/team_service.dart';
import 'package:flutter/foundation.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService;

  models.Team? _currentTeam;
  bool _isLoading = false;
  String? _error;

  /// Creates a new TeamProvider instance and automatically loads the user's current team.
  ///
  /// This constructor initializes the provider with the required team service and
  /// immediately attempts to load the user's current team information.
  ///
  /// Parameters:
  ///   - teamService: The service responsible for team-related API operations
  TeamProvider({required TeamService teamService})
    : _teamService = teamService {
    _loadCurrentTeam();
  }

  /// Returns the current team object if available.
  ///
  /// This getter provides access to the full team model with all its properties.
  models.Team? get currentTeam => _currentTeam;

  /// Indicates whether a loading operation is in progress.
  ///
  /// Use this to show loading indicators in the UI when operations are pending.
  bool get isLoading => _isLoading;

  /// Returns the most recent error message if an operation failed.
  ///
  /// Will be null if no error has occurred or if a new operation has started.
  String? get error => _error;

  /// Indicates whether the user is currently a member of a team.
  ///
  /// Returns true if the user has a team, false otherwise.
  bool get hasTeam => _currentTeam != null;

  /// Returns the name of the current team.
  ///
  /// If no team is available, returns 'No Team' as a fallback.
  String get teamName => _currentTeam?.prefs.data['teamName'] ?? 'No Team';

  /// Returns the team number of the current team.
  ///
  /// If no team is available, returns 0 as a fallback.
  int get teamNumber => _currentTeam?.prefs.data['teamNumber'] ?? 0;

  /// Loads the user's current team from the backend service.
  ///
  /// This private method is called during initialization to fetch the user's
  /// team data. It handles the loading state and error handling automatically.
  /// If the user isn't part of any team, the _currentTeam will remain null.
  Future<void> _loadCurrentTeam() async {
    _setLoading(true);

    try {
      _currentTeam = await _teamService.getCurrentTeam();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load current team: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the loading state and notifies listeners of the change.
  ///
  /// This helper method centralizes the loading state management to reduce
  /// boilerplate code throughout the provider. It also clears any previous
  /// error messages when a new operation starts.
  ///
  /// Parameters:
  ///   - loading: Whether a loading operation is in progress
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = loading ? null : _error;
    notifyListeners();
  }

  /// Creates a new team with the specified name and number.
  ///
  /// This method creates a new team and automatically sets it as the current team
  /// for the user. The user will be assigned the specified roles within the team.
  ///
  /// Parameters:
  ///   - teamName: The display name for the team
  ///   - teamNumber: The team's official number (e.g., FRC team number)
  ///   - roles: List of roles to assign to the user, defaults to ['owner']
  ///
  /// Returns:
  ///   A boolean indicating whether the operation was successful
  Future<bool> createTeam({
    required String teamName,
    required int teamNumber,
    List<String> roles = const ['owner'],
  }) async {
    _setLoading(true);

    try {
      _currentTeam = await _teamService.createTeam(
        teamName: teamName,
        teamNumber: teamNumber,
        roles: roles,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to create team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches a team by its ID and sets it as the current team.
  ///
  /// This method retrieves a team's details using its unique identifier
  /// and updates the current team state if successful.
  ///
  /// Parameters:
  ///   - teamId: The unique identifier of the team to retrieve
  ///
  /// Returns:
  ///   A boolean indicating whether the operation was successful
  Future<bool> getTeam(String teamId) async {
    _setLoading(true);

    try {
      _currentTeam = await _teamService.getTeam(teamId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to get team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes the current team if the user has permission.
  ///
  /// This method permanently removes the team from the system. This action
  /// cannot be undone and will affect all team members. The method will only
  /// succeed if the user has appropriate permissions (typically owner role).
  ///
  /// Returns:
  ///   A boolean indicating whether the operation was successful.
  ///   Returns false if there is no current team to delete.
  Future<bool> deleteCurrentTeam() async {
    _setLoading(true);

    try {
      if (_currentTeam != null) {
        await _teamService.deleteTeam(_currentTeam!.$id);
        _currentTeam = null;
        return true;
      } else {
        debugPrint('No team to delete');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to delete team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the current team data from the backend.
  ///
  /// This method fetches the latest team information from the server,
  /// which is useful when team details might have been updated by other users.
  /// If the user is no longer part of the team, _currentTeam will be set to null.
  Future<void> refreshCurrentTeam() async {
    _setLoading(true);

    try {
      _currentTeam = await _teamService.getCurrentTeam();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to refresh current team: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Removes the current user from their team.
  ///
  /// This method allows a user to leave their current team without deleting it.
  /// The team will continue to exist for other members. After leaving,
  /// the current team will be set to null.
  ///
  /// Returns:
  ///   A boolean indicating whether the operation was successful.
  ///   Returns false if there is no current team to leave.
  Future<bool> leaveTeam() async {
    _setLoading(true);

    try {
      if (_currentTeam != null) {
        models.MembershipList memberships = await _teamService.getMemberships(
          _currentTeam!.$id,
        );

        // Get the current user ID from the team service
        String currentUserId = await _teamService.getCurrentUserId();

        String membershipId =
            memberships.memberships
                .firstWhere((membership) => membership.userId == currentUserId)
                .$id;

        await _teamService.leaveTeam(_currentTeam!.$id, membershipId);
        _currentTeam = null;
        return true;
      } else {
        debugPrint('No team to leave');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to leave team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a join code for the current user's team.
  Future<String?> createJoinCode() async {
    _setLoading(true);

    try {
      String joinCode = await _teamService.createJoinCode(_currentTeam!.$id);
      return joinCode;
    } catch (e) {
      _error = e.toString();
      debugPrint(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Uses a join code to add the current user to a team.
  Future<bool> useJoinCode(String joinCode) async {
    _setLoading(true);

    try {
      await _teamService.useJoinCode(joinCode);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
