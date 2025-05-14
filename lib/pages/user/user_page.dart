import 'package:beariscope/providers/auth_provider.dart';
import 'package:beariscope/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Builder(
      builder: (context) {
        if (!isAuthenticated) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Text('Sign in to view your account details.'),
              FilledButton.icon(
                onPressed: () {
                  context.go('/welcome');
                },
                icon: const Icon(Symbols.logout_rounded),
                label: const Text('Exit Guest Mode'),
              ),
            ],
          );
        } else if (authProvider.user != null) {
          final user = authProvider.user!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              ProfilePicture(size: 48, ring: false),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  final success = await authProvider.signOut();

                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully'),
                        ),
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
                icon:
                    authProvider.isLoading
                        ? null
                        : Icon(Symbols.logout_rounded),
                label:
                    authProvider.isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                        : Text('Sign Out'),
              ),
            ],
          );
        } else {
          return const Text('No user data available');
        }
      },
    );
  }
}
