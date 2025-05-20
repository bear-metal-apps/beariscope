import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TileableCardView extends StatelessWidget {
  final List<Widget> children;

  const TileableCardView({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = max(1, constraints.maxWidth ~/ 300);

          return MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            itemCount: children.length,
            itemBuilder: (context, index) {
              return children[index];
            },
          );
        },
      ),
    );
  }
}
