import 'package:beariscope/custom_fab.dart';
import 'package:beariscope/pages/data/data_page.dart';
import 'package:beariscope/pages/home/home_page.dart';
import 'package:beariscope/pages/scout/scout_page.dart';
import 'package:beariscope/pages/user/user_page.dart';
import 'package:beariscope/widgets/profile_picture.dart';
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
    const UserPage(),
  ];

  bool _isFabOpen = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    bool showNavigationRail() {
      return screenWidth > 600 && screenHeight > 440;
    }

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
            const Text('Beariscope'),
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
        ],
      ),
      bottomNavigationBar:
          !(showNavigationRail())
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
                    icon: ProfilePicture(ring: false, size: 12),
                    label: 'You',
                  ),
                ],
              )
              : null,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      body: Row(
        children: [
          if (showNavigationRail())
            NavigationRail(
              leading: Row(
                children: [
                  CustomFab(
                    direction: SpeedDialDirection.down,
                    switchLabelPosition: true,
                    elevation: 0.0,
                    isOpenOnStart: _isFabOpen,
                    onToggle: (bool isOpen) {
                      setState(() {
                        _isFabOpen = isOpen;
                      });
                    },
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
                  icon: ProfilePicture(ring: false, size: 12),
                  label: const Text('You'),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          // if (showNavigationRail()) VerticalDivider(),
          Expanded(child: Center(child: _pages[_selectedIndex])),
        ],
      ),
      floatingActionButton:
          !(showNavigationRail())
              ? CustomFab(
                isOpenOnStart: _isFabOpen,
                onToggle: (bool isOpen) {
                  setState(() {
                    _isFabOpen = isOpen;
                  });
                },
              ).build(context)
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
