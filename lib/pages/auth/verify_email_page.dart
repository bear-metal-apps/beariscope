import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatelessWidget {
  final String userId;
  final String secret;
  final String expire;

  const VerifyEmailPage({
    super.key,
    required this.userId,
    required this.secret,
    required this.expire,
  });

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty || secret.isEmpty || expire.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Invalid verification link')),
      );
    }

    if (DateTime.now().isAfter(DateTime.parse(expire))) {
      return const Scaffold(
        body: Center(child: Text('Verification link has expired')),
      );
    }

    return FutureBuilder<Token>(
      future: context.read<AuthProvider>().account.updateVerification(
        userId: userId,
        secret: secret,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Verification failed: \\${snapshot.error}'),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Email verified! You may close this tab.'),
            ),
          );
        }
      },
    );
  }
}
