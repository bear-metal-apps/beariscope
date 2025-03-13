import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'lib/assets/scuffed_logo.svg',
              height: 128,

              colorFilter: const ColorFilter.mode(
                Colors.amber,
                BlendMode.srcATop,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Bearscout!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Let\'s get started!'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/welcome/signup');
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.go('/welcome/login');
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
