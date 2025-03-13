import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bearscout/pages/home/home_page.dart';
import 'package:bearscout/pages/scout/scout_page.dart';
import 'package:bearscout/pages/piclkist/picklist_page.dart';
import 'package:bearscout/pages/team/team_page.dart';
import 'package:bearscout/dialogs/profile_dialog.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  static final List<Widget> _pages = [
    const HomePage(),
    const ScoutPage(),
    const PicklistPage(),
    const TeamPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/scuffed_logo.svg',
              width: 28,
              colorFilter: const ColorFilter.mode(
                Colors.amber,
                BlendMode.srcATop,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Bearscout'),
          ],
        ),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          IconButton(
            icon: const Icon(Symbols.cloud_done_rounded, fill: 1.0),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          IconButton(
            icon: const Icon(Symbols.notifications_rounded, fill: 1.0),
            onPressed: () {
              HapticFeedback.lightImpact();
              FirebaseCrashlytics.instance.crash();
            },
          ),
          Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileDialog(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.amber,
                    radius: 16,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundImage: const NetworkImage(
                        'https://picsum.photos/200',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(child: _pages[_selectedIndex]),
              NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Symbols.home_rounded,
                      weight: 600,
                      fill: _selectedIndex == 0 ? 1.0 : 0.0,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Symbols.explore_rounded,
                      weight: 600,
                      fill: _selectedIndex == 1 ? 1.0 : 0.0,
                    ),
                    label: 'Scout',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Symbols.ballot_rounded,
                      weight: 600,
                      fill: _selectedIndex == 2 ? 1.0 : 0.0,
                    ),
                    label: 'Picklist',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Symbols.group_rounded,
                      weight: 600,
                      fill: _selectedIndex == 3 ? 1.0 : 0.0,
                    ),
                    label: 'Team',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
