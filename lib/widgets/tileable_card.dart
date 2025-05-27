import 'package:flutter/material.dart';

class TileableCard extends StatelessWidget {
  final Widget child;

  const TileableCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(padding: const EdgeInsets.all(24.0), child: child),
      ),
    );
  }
}
