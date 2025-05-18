import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AuthService {
  final Client client;
  final Account account;

  AuthService({required this.client}) : account = Account(client);

  // Used to check if we're logged in
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } catch (e) {
      return null;
    }
  }

  // Might be useful someday
  Future<models.Session?> getSession() async {
    try {
      return await account.getSession(sessionId: 'current');
    } catch (e) {
      return null;
    }
  }

  // Sign up but don't sign in
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

  Future<models.Session> signIn({
    required String email,
    required String password,
  }) async {
    return await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  // Sign up and sign in at the same time!!!
  Future<(models.User, models.Session)> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = await createUser(email: email, password: password, name: name);

    final session = await signIn(email: email, password: password);

    return (user, session);
  }

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
