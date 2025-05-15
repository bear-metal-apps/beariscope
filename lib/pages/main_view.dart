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
        backgroundColor:
            showNavigationRail()
                ? Theme.of(context).colorScheme.surfaceContainer
                : null,
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/scuffed_logo.svg',
              width: 28,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Symbols.notifications_rounded, fill: 1.0),
            onPressed: () {},
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
                    icon: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _selectedIndex == 0 ? 0.0 : 1.0,
                        end: _selectedIndex == 0 ? 1.0 : 0.0,
                      ),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.fastOutSlowIn,
                      builder: (context, value, child) {
                        return Icon(
                          Symbols.home_rounded,
                          weight: 600,
                          fill: value,
                        );
                      },
                    ),
                    label: 'Home',
                    tooltip: "",
                  ),
                  NavigationDestination(
                    icon: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _selectedIndex == 1 ? 0.0 : 1.0,
                        end: _selectedIndex == 1 ? 1.0 : 0.0,
                      ),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.fastOutSlowIn,
                      builder: (context, value, child) {
                        return Icon(
                          Symbols.explore_rounded,
                          weight: 600,
                          fill: value,
                        );
                      },
                    ),
                    label: 'Scout',
                    tooltip: "",
                  ),
                  NavigationDestination(
                    icon: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _selectedIndex == 2 ? 0.0 : 1.0,
                        end: _selectedIndex == 2 ? 1.0 : 0.0,
                      ),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.fastOutSlowIn,
                      builder: (context, value, child) {
                        return Icon(
                          Symbols.chart_data_rounded,
                          weight: 600,
                          fill: value,
                        );
                      },
                    ),
                    label: 'Data',
                    tooltip: "",
                  ),
                  NavigationDestination(
                    icon: ProfilePicture(ring: false, size: 12),
                    label: 'You',
                    tooltip: "",
                  ),
                ],
              )
              : null,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      body: Row(
        children: [
          if (showNavigationRail())
            NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              leading: CustomFab(
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
              groupAlignment: -1.0,
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _selectedIndex == 0 ? 0.0 : 1.0,
                      end: _selectedIndex == 0 ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.fastOutSlowIn,
                    builder: (context, value, child) {
                      return Icon(
                        Symbols.home_rounded,
                        weight: 600,
                        fill: value,
                      );
                    },
                  ),
                  label: Text('Home'),
                  padding: EdgeInsets.only(top: 10, bottom: 6),
                ),
                NavigationRailDestination(
                  icon: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _selectedIndex == 1 ? 0.0 : 1.0,
                      end: _selectedIndex == 1 ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.fastOutSlowIn,
                    builder: (context, value, child) {
                      return Icon(
                        Symbols.explore_rounded,
                        weight: 600,
                        fill: value,
                      );
                    },
                  ),
                  label: Text('Scout'),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                ),
                NavigationRailDestination(
                  icon: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _selectedIndex == 2 ? 0.0 : 1.0,
                      end: _selectedIndex == 2 ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.fastOutSlowIn,
                    builder: (context, value, child) {
                      return Icon(
                        Symbols.chart_data_rounded,
                        weight: 600,
                        fill: value,
                      );
                    },
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
