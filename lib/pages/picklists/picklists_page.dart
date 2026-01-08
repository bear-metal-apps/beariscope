import 'package:beariscope/pages/main_view.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/ui/widgets/text_divider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PicklistsPage extends StatefulWidget {
  const PicklistsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return PicklistsPageState();
  }
}

class PicklistsPageState extends State<PicklistsPage> {
  final TextEditingController joinCodeTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picklists'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter join code',
                ),
                controller: joinCodeTEC,
              ),
            ),
            SizedBox(height: 12),
            FilledButton(onPressed: () {}, child: Text('Join')),
            SizedBox(height: 20),
            TextDivider(maxWidth: 150),
            SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.push('/picklists/create'),
              child: Text('Create'),
            ),
            SizedBox(height: 62),
          ],
        ),
      ),
    );
  }
}
