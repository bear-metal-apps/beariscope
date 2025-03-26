import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: <Widget>[
            SvgPicture.asset(
              'lib/assets/scuffed_logo.svg',
              height: 128,
              colorFilter: const ColorFilter.mode(
                Colors.amber,
                BlendMode.srcATop,
              ),
            ),
            const Text(
              'Welcome to Bear Scout!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.go('/welcome/signup');
              },
              label: const Text('Create Account'),
              icon: const Icon(Symbols.person_add_rounded),
            ),
            OutlinedButton.icon(
              onPressed: () {
                context.go('/welcome/login');
              },
              label: const Text('Log In'),
              icon: const Icon(Symbols.person_rounded),
            ),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Guest Mode'),
                      content: const Text(
                        'Guest Mode lets you try Bear Scout without using an account. Data will not be saved or synced to the cloud.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/home');
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    );
                  },
                );
              },
              label: const Text('Guest Mode'),
              icon: const Icon(Symbols.eyeglasses_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
