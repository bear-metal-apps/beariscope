import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_widgets.dart';

import 'pits_scouting_data_provider.dart';

class _PitsScoutingHomePage extends StatelessWidget {
  const _PitsScoutingHomePage({super.key});
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
          children: [NumberTextField(labelText: 'Meow',), RadioButton(inputs: ['meow', 'meow2'],), MultipleChoice(), DropdownButtonOneChoice(), SegmentedSlider()],
        ),
      ),
    );
  }
}

// for (var i = 0; i < 50; i++) {
//   ref.read(PitsScoutingDatabaseProvider.notifier).editData(PitsScoutingTeamData('Team $i', i, false, 'Notes:'));
// }