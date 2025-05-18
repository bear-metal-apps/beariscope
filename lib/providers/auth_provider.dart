import 'package:appwrite/models.dart' as models;
import 'package:beariscope/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  models.User? _user;
  models.Session? _session;
  bool _isLoading = false;
  String? _error;

  // Are we logged in?
  AuthProvider({required AuthService authService})
    : _authService = authService {
    _checkAuthState();
  }

  // Getters
  models.User? get user => _user;

  models.Session? get session => _session;

  bool get isAuthed => _user != null;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String get userName => _user?.name ?? 'Guest';

  String get userEmail => _user?.email ?? '';

  // Again, are we logged in?
  Future<void> _checkAuthState() async {
    _setLoading(true);

    // Try to get existing session and restore it
    try {
      _user = await _authService.getCurrentUser();
      _session = await _authService.getSession();
    } catch (e) {
      debugPrint('Auth state check failed: ${e.toString()}');
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

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);

    try {
      // Create session first, then get user details
      _session = await _authService.signIn(email: email, password: password);
      _user = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Login failed: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      _user = result.$1;
      _session = result.$2;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Sign up failed: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // This is jack, signing out
  Future<bool> signOut() async {
    if (_user == null) return true; // Already logged out

    _setLoading(true);

    try {
      await _authService.signOut();
      _user = null;
      _session = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Logout failed: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data without full login
  // Useful for when we implement updating user details in the app
  Future<void> refreshUser() async {
    if (!isAuthed) return;

    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Just log errors but don't change state
      debugPrint('User refresh failed: $e');
    }
  }
}
