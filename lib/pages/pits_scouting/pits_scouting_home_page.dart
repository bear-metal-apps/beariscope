import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod/riverpod.dart';

import 'pits_scouting_data_provider.dart';

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    for (var i = 0; i < 50; i++) {
      ref.read(PitsScoutingDatabaseProvider.notifier).editData(PitsScoutingTeamData('Team name', i, false, 'Notes'));
    }
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
      body: Center(child: Text('Pits Scouting Page')),
    );
  }
}
