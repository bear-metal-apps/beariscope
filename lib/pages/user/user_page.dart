import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/providers/user_info_provider.dart';
import 'package:libkoala/ui/widgets/profile_picture.dart';
import 'package:libkoala/ui/widgets/tileable_card.dart';
import 'package:libkoala/ui/widgets/tileable_card_view.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

      body: TileableCardView(children: [_buildUserCard(context, ref)]),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final userInfo = ref.watch(userInfoProvider);

    return TileableCard(
      child: Builder(
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              ProfilePicture(size: 48),
              Text(
                userInfo.value?.name ?? 'Unknown User',
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
                    await auth.logout();
                    // if (context.mounted) {
                    // context.go('/welcome');
                    // }
                  }
                },
                icon: Icon(Symbols.logout_rounded),
                label: Text('Sign Out'),
              ),
            ],
          );
        },
      ),
    );
  }
}
