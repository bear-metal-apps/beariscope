import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_widgets.dart';

class PitsScoutingHomePage extends StatelessWidget {
  const PitsScoutingHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pits Scouting'),
        leading:
            controller.isDesktop
                ? null
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: controller.openDrawer,
                ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [NumberTextField(), RadioButton(), MultipleChoice(), DropdownButtonOneChoice()],
        ),
      ),
    );
  }
}
