import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/main_view.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() =>
      _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final main = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: controller,
          hintText: 'Type Name Here',
          trailing: [
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add User',
              onPressed: () {},
            ),
          ],
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
      body: const Center(child: Text('User Selection Page')),
    );
  }
}
