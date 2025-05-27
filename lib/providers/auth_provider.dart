import 'package:appwrite/models.dart' as models;
import 'package:beariscope/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  models.User? _user;
  models.Session? _session;
  bool _isLoading = false;
  String? _error;

  /// Creates a new AuthProvider instance and automatically checks the authentication state.
  ///
  /// This constructor initializes the provider with the required authentication service
  /// and immediately attempts to restore any existing user session.
  ///
  /// Parameters:
  ///   - authService: The service responsible for authentication-related API operations
  AuthProvider({required AuthService authService})
    : _authService = authService {
    _checkAuthState();
  }

  /// Returns the current user object if authenticated.
  ///
  /// This getter provides access to the full user model with all its properties.
  models.User? get user => _user;

  /// Returns the current session object if available.
  ///
  /// This getter provides access to the session details like token and expiry.
  models.Session? get session => _session;

  /// Indicates whether the user is currently authenticated.
  ///
  /// Returns true if the user is logged in, false otherwise.
  bool get isAuthed => _user != null;

  /// Indicates whether an authentication operation is in progress.
  ///
  /// Use this to show loading indicators in the UI when operations are pending.
  bool get isLoading => _isLoading;

  /// Returns the most recent authentication error message.
  ///
  /// Will be null if no error has occurred or if a new operation has started.
  String? get error => _error;

  /// Returns the name of the current user.
  ///
  /// If no user is authenticated, returns 'Guest' as a fallback.
  String get userName => _user?.name ?? 'Guest';

  /// Returns the email address of the current user.
  ///
  /// If no user is authenticated, returns an empty string.
  String get userEmail => _user?.email ?? '';

  /// Checks if the user is already authenticated and restores the session.
  ///
  /// This private method is called during initialization to attempt to restore
  /// any existing user session from storage. If a valid session exists, the user
  /// will be automatically logged in without needing to re-enter credentials.
  Future<void> _checkAuthState() async {
    _setLoading(true);

    try {
      _user = await _authService.getCurrentUser();
      _session = await _authService.getSession();
    } catch (e) {
      debugPrint('Auth state check failed: ${e.toString()}');
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

  /// Authenticates a user with their email and password.
  ///
  /// This method attempts to sign in the user with the provided credentials.
  /// If successful, it updates the user and session state and returns true.
  ///
  /// Parameters:
  ///   - email: The user's email address
  ///   - password: The user's password
  ///
  /// Returns:
  ///   A boolean indicating whether the sign-in was successful
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);

    try {
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

  /// Creates a new user account and signs them in.
  ///
  /// This method registers a new user with the provided information and
  /// automatically signs them in if the registration is successful.
  ///
  /// Parameters:
  ///   - email: The email address for the new account
  ///   - password: The password for the new account
  ///   - name: The display name for the new user
  ///
  /// Returns:
  ///   A boolean indicating whether the sign-up was successful
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

  /// Signs out the current user.
  ///
  /// This method ends the user's session and clears all authentication state.
  /// After signing out, the user will need to sign in again to access protected resources.
  ///
  /// Returns:
  ///   A boolean indicating whether the sign-out was successful.
  ///   Returns true if the user was already signed out.
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

  /// Refreshes the current user's data from the backend.
  ///
  /// This method fetches the latest user information without requiring a full
  /// re-authentication. It's useful after updating user profile details to
  /// ensure the local state reflects the latest changes.
  ///
  /// Does nothing if the user is not authenticated.
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
