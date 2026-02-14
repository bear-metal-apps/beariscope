import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:beariscope/pages/main_view.dart';

class UtilitiesPage extends StatefulWidget {
  const UtilitiesPage({super.key});

  @override
  State<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage> {
  final TextEditingController _searchTermTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: _searchTermTEC,
          hintText: 'Search...',
          elevation: WidgetStateProperty.all(0.0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Symbols.search_rounded),
        ),
        leading:
            main.isDesktop
                ? SizedBox(width: 48)
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: main.openDrawer,
                ),
        actions: [SizedBox(width: 48)],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16)),
        ),
      ),
    );
  }
}
