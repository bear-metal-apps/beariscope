import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Log in to an account'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate successful login
                context.read<SharedPreferences>().setBool('isLoggedIn', true);
                context.go('/home');
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
