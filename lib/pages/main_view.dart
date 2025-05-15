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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bool useNavigationRail = screenWidth > 600 && screenHeight >= 500;

    return Scaffold(
      appBar: !useNavigationRail ? _buildAppBar() : null,
      bottomNavigationBar: !useNavigationRail ? _buildNavBar() : null,
      body: Row(
        children: [
          if (useNavigationRail) _buildNavRail(),
          Expanded(child: Center(child: _pages[_selectedIndex])),
        ],
      ),
      floatingActionButton:
          !useNavigationRail ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
    );
  }

  AppBar? _buildAppBar() {
    return AppBar(
      centerTitle: false,
      backgroundColor: null,
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
      ],
    );
  }

  NavigationBar _buildNavBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
      destinations: [
        _buildNavBarDestination(0, Symbols.home_rounded, 'Home'),
        _buildNavBarDestination(1, Symbols.explore_rounded, 'Scout'),
        _buildNavBarDestination(2, Symbols.chart_data_rounded, 'Data'),
        NavigationDestination(
          icon: ProfilePicture(ring: false, size: 12),
          label: 'You',
          tooltip: "",
        ),
      ],
    );
  }

  NavigationDestination _buildNavBarDestination(
    int index,
    IconData icon,
    String label,
  ) {
    return NavigationDestination(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: _selectedIndex == index ? 0.0 : 1.0,
          end: _selectedIndex == index ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        builder: (context, value, child) {
          return Icon(icon, weight: 600, fill: value);
        },
      ),
      label: label,
      tooltip: "",
    );
  }

  NavigationRail _buildNavRail() {
    return NavigationRail(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      leading: Column(
        children: [
          const SizedBox(height: 16),
          SvgPicture.asset(
            'lib/assets/scuffed_logo.svg',
            width: 28,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcATop,
            ),
          ),
          const SizedBox(height: 24),
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
        _buildNavRailDestination(
          0,
          Symbols.home_rounded,
          'Home',
          const EdgeInsets.only(top: 10, bottom: 6),
        ),
        _buildNavRailDestination(
          1,
          Symbols.explore_rounded,
          'Scout',
          const EdgeInsets.symmetric(vertical: 6.0),
        ),
        _buildNavRailDestination(
          2,
          Symbols.chart_data_rounded,
          'Data',
          const EdgeInsets.symmetric(vertical: 6.0),
        ),
        NavigationRailDestination(
          icon: ProfilePicture(ring: false, size: 12),
          label: const Text('You'),
          padding: const EdgeInsets.symmetric(vertical: 6.0),
        ),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Symbols.cloud_done_rounded, fill: 1.0),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  NavigationRailDestination _buildNavRailDestination(
    int index,
    IconData icon,
    String label,
    EdgeInsetsGeometry padding,
  ) {
    return NavigationRailDestination(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: _selectedIndex == index ? 0.0 : 1.0,
          end: _selectedIndex == index ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        builder: (context, value, child) {
          return Icon(icon, weight: 600, fill: value);
        },
      ),
      label: Text(label),
      padding: padding,
    );
  }

  Widget _buildFloatingActionButton() {
    return CustomFab(
      isOpenOnStart: _isFabOpen,
      onToggle: (bool isOpen) {
        setState(() {
          _isFabOpen = isOpen;
        });
      },
    ).build(context);
  }

  void _handleNavigation(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }
}
