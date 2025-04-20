import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.read<Client>();
    final account = Account(client);

    final isLoggedIn =
        context.read<SharedPreferences>().getBool('isLoggedIn') ?? false;

    return AlertDialog(
      title: const Text('Account Details'),
      content: FutureBuilder<models.User>(
        future: account.get(),
        builder: (context, snapshot) {
          if (!isLoggedIn) {
            return const Text('Sign in to view your account details.');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Text('Name: ${user.name}\nEmail: ${user.email}');
          } else {
            return const Text('No user data available');
          }
        },
      ),
      actions: [
        isLoggedIn
            ? TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await account.deleteSession(sessionId: 'current');

                  if (context.mounted) {
                    context.read<SharedPreferences>().setBool(
                      'isLoggedIn',
                      false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully')),
                    );

                    context.go('/welcome');
                  }
                } catch (error) {
                  // Only show error if context is still mounted
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $error')),
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
