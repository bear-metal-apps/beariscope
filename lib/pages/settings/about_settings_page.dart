import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Column(
          children: [
            Text(
              style: TextStyle(fontSize: 30),
              'About Bear Metal'
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Image(image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGsrfomCbhbrN0fotdpuRs-1Yrb0fvKw_lxA&s'))
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                style: TextStyle(fontSize: 14),
                  'Bear Metal 2046 is a team. Yeah. Crazy. We\'re in FRC or First Robotics Competition. idk man. ajrwrgheorghweorgbwoirugohqwptghwejbrgioejbrielrnmawrislgjhlgnawjrngbijalkfgnbjdlfkgbanjroglkbwanrgkljmhgslfjgnmflgkjns fogln mim just tryna make it longer Here\'s a paragraph. \n'
                  'Here\s the paragraph you ordered. Now have fun. I guess. Why are you still here.'
              ),
            )
            // here lies a child. take care of him.
            // here lies another child. take care of him.
            // no, there are no gravestones. what are you thinking about.
            // don't you dare there are CHILDREN HERE...
            // THERE ARE CHILDREN. NONONNONONONNONONONONONONONNONNO
            // NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
            // STOPPPPP ITTTTTTTTT
            // welp, they're dead now. it's all your fault.
            // what do you mean, you want more?
            // no. please no.
          ],
        ),
      ),
    );
  }
}
