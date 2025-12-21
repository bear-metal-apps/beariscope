import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class DriveTeamPage extends StatelessWidget {
  const DriveTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive Team'),
        leading:
            controller.isDesktop
                ? null
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: controller.openDrawer,
                ),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/drive_team/match_preview/23'),
          child: const Text('Start'),
        ),
      ),
    );
  }
}
