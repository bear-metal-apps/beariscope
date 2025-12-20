import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: <Widget>[
            SvgPicture.asset(
              'assets/beariscope_head.svg',
              height: 128,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcATop,
              ),
            ),
            const Text(
              'Welcome to Beariscope!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IntrinsicWidth(
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      auth.login([
                        'openid',
                        'profile',
                        'offline_access',
                        'User.Read',
                        'api://bearmet.al/honeycomb/access',
                      ]);
                    },
                    label: const Text('Sign In With BMBC Account'),
                    icon: const Icon(Symbols.login_rounded),
                  ),
                  // OutlinedButton.icon(
                  //   onPressed: () {
                  //     showDialog(
                  //       context: context,
                  //       builder: (context) {
                  //         return AlertDialog(
                  //           title: const Text('Guest Mode'),
                  //           content: const Text(
                  //             'Guest Mode lets you try Beariscope without using an account. Data will not be saved or synced to the cloud.',
                  //           ),
                  //           actions: [
                  //             TextButton(
                  //               onPressed: () {
                  //                 Navigator.of(context).pop();
                  //               },
                  //               child: const Text('Back'),
                  //             ),
                  //             TextButton(
                  //               onPressed: () {
                  //                 context.go('/home');
                  //               },
                  //               child: const Text('Continue'),
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     );
                  //   },
                  //   label: const Text('Guest Mode'),
                  //   icon: const Icon(Symbols.eyeglasses_rounded),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
