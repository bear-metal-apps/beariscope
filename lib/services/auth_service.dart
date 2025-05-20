import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AuthService {
  final Client client;
  final Account account;

  /// Creates a new AuthService instance with the provided Appwrite client.
  ///
  /// This service handles all authentication-related API operations including
  /// user registration, login, session management, and account operations.
  ///
  /// Parameters:
  ///   - client: The Appwrite client instance used for API communication
  AuthService({required this.client}) : account = Account(client);

  /// Retrieves the currently authenticated user.
  ///
  /// This method attempts to fetch the user details from the current session.
  /// It's commonly used to check if a user is logged in and to access their profile information.
  ///
  /// Returns:
  ///   The User object if authenticated, or null if no active session exists
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the current active session.
  ///
  /// This method fetches details about the user's current authentication session,
  /// including tokens and expiry information.
  ///
  /// Returns:
  ///   The Session object if an active session exists, or null otherwise
  Future<models.Session?> getSession() async {
    try {
      return await account.getSession(sessionId: 'current');
    } catch (e) {
      return null;
    }
  }

  /// Creates a new user account without signing them in.
  ///
  /// This method registers a new user in the system but doesn't create a session.
  /// It's useful when you want to create accounts programmatically without
  /// immediately authenticating the user.
  ///
  /// Parameters:
  ///   - email: The email address for the new account
  ///   - password: The password for the new account
  ///   - name: The display name for the new user
  ///
  /// Returns:
  ///   The newly created User object
  Future<models.User> createUser({
    required String email,
    required String password,
    required String name,
  }) async {
    return await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  /// Authenticates a user with their email and password.
  ///
  /// This method creates a new session for the user with the provided credentials.
  /// If successful, the session can be used for subsequent authenticated requests.
  ///
  /// Parameters:
  ///   - email: The user's email address
  ///   - password: The user's password
  ///
  /// Returns:
  ///   A Session object containing authentication tokens and expiry information
  Future<models.Session> signIn({
    required String email,
    required String password,
  }) async {
    return await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  /// Creates a new user account and immediately signs them in.
  ///
  /// This convenience method combines user creation and authentication in one step.
  /// It first creates the user account and then establishes a session for them.
  ///
  /// Parameters:
  ///   - email: The email address for the new account
  ///   - password: The password for the new account
  ///   - name: The display name for the new user
  ///
  /// Returns:
  ///   A tuple containing the User object and Session object
  Future<(models.User, models.Session)> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = await createUser(email: email, password: password, name: name);
    final session = await signIn(email: email, password: password);
    return (user, session);
  }

  /// Ends the current user session.
  ///
  /// This method invalidates the current authentication session, effectively
  /// logging the user out of the application. After calling this method,
  /// the user will need to sign in again to access protected resources.
  ///
  /// Throws:
  ///   Any exceptions encountered during the sign-out process
  Future<void> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }
}
