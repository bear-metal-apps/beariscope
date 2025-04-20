import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as Models;
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
      content: FutureBuilder<Models.User>(
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
              onPressed: () {
                Navigator.of(context).pop();
                account
                    .deleteSession(sessionId: 'current')
                    .then((_) {
                      context.read<SharedPreferences>().setBool(
                        'isLoggedIn',
                        false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully'),
                        ),
                      );
                      if (context.mounted) {
                        context.go('/welcome');
                      }
                    })
                    .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $error')),
                      );
                    });
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
