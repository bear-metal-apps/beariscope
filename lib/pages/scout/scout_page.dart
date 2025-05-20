import 'package:flutter/material.dart';

class ScoutPage extends StatelessWidget {
  const ScoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scout')),
      body: const Center(child: Text('Scout Page')),
    );
  }
}
