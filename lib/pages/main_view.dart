import 'package:bearscout/custom_fab.dart';
import 'package:bearscout/dialogs/profile_dialog.dart';
import 'package:bearscout/pages/data/data_page.dart';
import 'package:bearscout/pages/home/home_page.dart';
import 'package:bearscout/pages/scout/scout_page.dart';
import 'package:bearscout/pages/team/team_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    const DataPage(),
    const TeamPage(),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

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
            const Text('Bear Scout'),
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
            },
          ),
          Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const ProfileDialog();
                      },
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
      bottomNavigationBar:
          !(screenWidth > 600)
              ? NavigationBar(
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
                      Symbols.chart_data_rounded,
                      weight: 600,
                      fill: _selectedIndex == 2 ? 1.0 : 0.0,
                    ),
                    label: 'Data',
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
              )
              : null,
      body: Row(
        children: [
          if (screenWidth > 600)
            NavigationRail(
              leading: Row(
                children: [
                  CustomFab(
                    direction: SpeedDialDirection.down,
                    switchLabelPosition: true,
                    elevation: 0.0,
                  ).build(context),
                ],
              ),
              groupAlignment: -1.0,
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(
                    Symbols.home_rounded,
                    weight: 600,
                    fill: _selectedIndex == 0 ? 1.0 : 0.0,
                  ),
                  label: Text('Home'),
                  padding: EdgeInsets.only(top: 10, bottom: 6),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Symbols.explore_rounded,
                    weight: 600,
                    fill: _selectedIndex == 1 ? 1.0 : 0.0,
                  ),
                  label: Text('Scout'),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Symbols.chart_data_rounded,
                    weight: 600,
                    fill: _selectedIndex == 2 ? 1.0 : 0.0,
                  ),
                  label: Text('Data'),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Symbols.group_rounded,
                    weight: 600,
                    fill: _selectedIndex == 3 ? 1.0 : 0.0,
                  ),
                  label: const Text('Team'),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          // if (screenWidth > 600) VerticalDivider(),
          Expanded(child: Center(child: _pages[_selectedIndex])),
        ],
      ),
      floatingActionButton:
          !(screenWidth > 600) ? CustomFab().build(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
