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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              spacing: 16,
              children: [
                UpNextWidget(
                  matchKey: '2026wabon_qm11',
                  time: 'Starts at 10:05 AM',
                ),
                UpNextWidget(
                  matchKey: '2026wabon_qm12',
                  time: 'Starts at 10:25 AM',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
