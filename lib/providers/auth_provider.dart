import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  models.User? _user;
  models.Session? _session;
  bool _isLoading = false;
  String? _error;

  // Initialize and check if user is already logged in
  AuthProvider({required AuthService authService})
    : _authService = authService {
    _checkAuthState();
  }

  // Getters
  models.User? get user => _user;
  models.Session? get session => _session;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get userName => _user?.name ?? 'Guest';

  Future<void> _checkAuthState() async {
    _setLoading(true);

    try {
      // Try to get existing session
      _user = await _authService.getCurrentUser();
      _session = await _authService.getSession();
    } catch (e) {
      _error = e.toString();
      debugPrint('Auth state check failed: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Helper to reduce boilerplate
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = loading ? null : _error;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);

    try {
      // Create session first, then get user details
      _session = await _authService.createSession(
        email: email,
        password: password,
      );
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
      debugPrint('Registration error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Log the user out
  Future<bool> signOut() async {
    if (_user == null) return true; // Already logged out

    _setLoading(true);

    try {
      await _authService.deleteSession();
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
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Just log errors but don't change state
      debugPrint('User refresh failed: $e');
    }
  }
}
