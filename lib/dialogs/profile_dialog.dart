import 'package:beariscope/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/profile_picture.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return AlertDialog(
      content: Builder(
        builder: (context) {
          if (!isAuthenticated) {
            return const Text('Sign in to view your account details.');
          } else if (authProvider.isLoading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfilePicture(size: 32, ring: false),
                const SizedBox(height: 8),
                const CircularProgressIndicator(),
              ],
            );
          } else if (authProvider.error != null) {
            return Text('Error: ${authProvider.error}');
          } else if (authProvider.user != null) {
            final user = authProvider.user!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfilePicture(size: 32, ring: false),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            );
          } else {
            return const Text('No user data available');
          }
        },
      ),
      actions: [
        isAuthenticated
            ? TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await authProvider.signOut();

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully')),
                    );
                    context.go('/welcome');
                  } else if (authProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error signing out: ${authProvider.error}',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Sign Out'),
            )
            : TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/welcome');
              },
              child: const Text('Exit Guest Mode'),
            ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
