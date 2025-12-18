import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/up_next/up_next_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class UpNextPage extends StatelessWidget {
  const UpNextPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Up Next'),
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
          children: [
            UpNextWidget(
              match: 'Qualification 11',
              time: 'Next match in 20 Minutes',
              onPressed: () {
                print('meow');
              },
            ),
            UpNextWidget(
              match: 'Qualification 12',
              time: 'Next match in 30 Minutes',
              onPressed: () {
                print('meow');
              },
            ),
          ],
        ),
      ),
    );
  }
}
