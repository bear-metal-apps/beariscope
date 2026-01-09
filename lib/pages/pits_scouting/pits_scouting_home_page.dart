import 'package:beariscope/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod/riverpod.dart';

class PitsScoutingHomePage extends ConsumerStatefulWidget {
  const PitsScoutingHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PitsScoutingHomePageState();
}

class PitsScoutingHomePageState extends ConsumerState<PitsScoutingHomePage> {
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
          hintText: 'Team name or number',
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search_rounded),

          trailing: [
            IconButton(
              icon: Icon(Icons.filter_list_rounded),
              tooltip: 'Filter & Sort',
              onPressed: () {},
            ),
          ],
        ),
        leading:
            main.isDesktop
                ? SizedBox(width: 40)
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: main.openDrawer,
                ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PitsScoutingTeamCard(teamName: 'Bear Metal', teamNumber: '2046')
          ],
        ),
      ),
    );
  }
}

class PitsScoutingTeamCard extends StatelessWidget {
  final String teamName;
  final String teamNumber;
  final double? height;
  final bool? scouted;

  const PitsScoutingTeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
    this.height,
    this.scouted
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => _ScoutingPage(
                    teamNumber: teamNumber,
                    teamName: teamName,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: height ?? 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        teamNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox(height: 89)),
                  scouted ?? false == false ?
                      Text(
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        'Not Scouted'
                      ) :
                      Text(
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        'Scouted'
                      )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoutingPage extends StatefulWidget {
  final String teamName;
  final String teamNumber;

  const _ScoutingPage({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  State<_ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends State<_ScoutingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scouting: Team ${widget.teamNumber}'),
        ),
        body: Center()
    );
  }
}
