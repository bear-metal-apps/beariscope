import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class DriveTeamNotesPage extends StatefulWidget {
  final String matchId;

  const DriveTeamNotesPage({super.key, required this.matchId});

  @override
  State<DriveTeamNotesPage> createState() => _DriveTeamNotesPageState();
}

class _DriveTeamNotesPageState extends State<DriveTeamNotesPage> {
  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Qualifier ${widget.matchId}'),
        leading:
            controller.isDesktop
                ? null
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: controller.openDrawer,
                ),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              context.go(
                '/drive_team/match_preview/${int.tryParse(widget.matchId)!}',
              );
            },
            icon: Icon(Symbols.arrow_back),
          ),
          SizedBox(width: 12),
          FilledButton(
            onPressed: () {
              context.go(
                '/drive_team/match_preview/${int.tryParse(widget.matchId)! + 1}',
              );
            },
            child: Text('Next'),
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 12),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2046',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Notes',
              ),
            ),
            SizedBox(height: 16),
            Text(
              '2910',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Notes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
