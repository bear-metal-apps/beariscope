import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AuthService {
  final Client client;
  final Account account;

  AuthService({required this.client}) : account = Account(client);

  // Check if user is logged in
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } catch (e) {
      return null;
    }
  }

  // Sign in
  Future<models.Session> createSession({
    required String email,
    required String password,
  }) async {
    return await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  // Sign up
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

  // Sign up and sign in
  Future<(models.User, models.Session)> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = await createUser(email: email, password: password, name: name);

    final session = await createSession(email: email, password: password);

    return (user, session);
  }

  // Sign out
  Future<void> deleteSession() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  // Get current session
  Future<models.Session?> getSession() async {
    try {
      return await account.getSession(sessionId: 'current');
    } catch (e) {
      return null;
    }
  }
}
