import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/ui/widgets/profile_picture.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          InkWell(
            onTap: () {
              context.push('/settings');
            },
            borderRadius: BorderRadius.circular(24),
            child: ProfilePicture(),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 16),
      ),
      body: const Center(child: Text('Home Page')),
    );
  }
}
