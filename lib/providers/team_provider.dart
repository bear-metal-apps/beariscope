import 'package:appwrite/models.dart' as models;
import 'package:beariscope/services/team_service.dart';
import 'package:flutter/foundation.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService;

  models.Team? _currentTeam;
  bool _isLoading = false;
  String? _error;

  // Load the user's current team
  TeamProvider({required TeamService teamService})
    : _teamService = teamService {
    _loadCurrentTeam();
  }

  // Getters
  models.Team? get currentTeam => _currentTeam;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasTeam => _currentTeam != null;

  String get teamName => _currentTeam?.prefs.data['teamName'] ?? 'No Team';

  int get teamNumber => _currentTeam?.prefs.data['teamNumber'] ?? 0;

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

  // Helper to reduce loading boilerplate
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = loading ? null : _error;
    notifyListeners();
  }

  Future<bool> createTeam({
    required String teamName,
    required int teamNumber,
    List<String> roles = const ['owner', 'lead', 'scout'],
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
}
