import 'package:beariscope/providers/auth_provider.dart';
import 'package:beariscope/widgets/profile_picture.dart';
import 'package:beariscope/widgets/tileable_card.dart';
import 'package:beariscope/widgets/tileable_card_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthed;

    List<Widget> cards = [
      _buildUserCard(context, authProvider),
      _buildTeamCard(context),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          !isAuthenticated
              ? Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sign in to view your account details.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.go('/welcome');
                    },
                    icon: const Icon(Symbols.logout_rounded),
                    label: const Text('Exit Guest Mode'),
                  ),
                ],
              )
              : TileableCardView(children: cards),
    );
  }

  Widget _buildUserCard(BuildContext context, AuthProvider authProvider) {
    return TileableCard(
      child: Builder(
        builder: (context) {
          if (authProvider.user != null) {
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
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context) {
    return TileableCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('You aren\'t on a team yet.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.go('/you/join_team');
            },
            icon: const Icon(Symbols.person_add_rounded),
            label: const Text('Join Team'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              context.go('/you/create_team');
            },
            icon: const Icon(Symbols.group_add_rounded),
            label: const Text('Create Team'),
          ),
        ],
      ),
    );
  }
}
