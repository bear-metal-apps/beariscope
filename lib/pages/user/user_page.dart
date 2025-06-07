import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/providers/team_provider.dart';
import 'package:libkoala/ui/widgets/profile_picture.dart';
import 'package:libkoala/ui/widgets/tileable_card.dart';
import 'package:libkoala/ui/widgets/tileable_card_view.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Account'),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings_rounded),
            onPressed: () {
              context.go('/you/settings');
            },
          ),
        ],
      ),

      body:
          !isAuthenticated
              ? Center(
                child: Column(
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
                ),
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
                    final bool confirmed =
                        await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Sign Out'),
                                content: const Text(
                                  'Are you sure you want to sign out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    child: const Text('Sign Out'),
                                  ),
                                ],
                              ),
                        ) ??
                        false;
                    if (confirmed && context.mounted) {
                      await authProvider.signOut();
                      if (context.mounted) {
                        context.go('/welcome');
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
                              color: Theme.of(context).colorScheme.onSurface,
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
    final teamProvider = context.watch<TeamProvider>();

    if (teamProvider.isLoading) {
      return TileableCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [const CircularProgressIndicator()],
          ),
        ),
      );
    }

    if (teamProvider.hasTeam) {
      return TileableCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              child: Image.network(
                'https://www.thebluealliance.com/avatar/2025/frc${teamProvider.teamNumber}.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) {
                  return Icon(
                    Symbols.group_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              teamProvider.teamName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Team ${teamProvider.teamNumber}'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.go('/you/manage_team/${teamProvider.currentTeam?.$id}');
              },
              icon: const Icon(Symbols.group_rounded),
              label: const Text('Manage Team'),
            ),
          ],
        ),
      );
    } else {
      return TileableCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You aren\'t on a team yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Join an existing team or create a new one',
              textAlign: TextAlign.center,
            ),
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
}
