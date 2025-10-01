import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PredictionsPage extends StatelessWidget {
  const PredictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictions'),
        leading:
            controller.isDesktop
                ? null
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: controller.openDrawer,
                ),
      ),
      body: const Center(child: Text('Predictions Page')),
    );
  }
}
