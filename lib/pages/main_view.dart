import 'package:beariscope/custom_fab.dart';
import 'package:beariscope/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/ui/widgets/profile_picture.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainView extends StatefulWidget {
  final Widget child;

  const MainView({super.key, required this.child});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  static const List<String> _routes = ['/home', '/scout', '/data', '/you'];

  int get _selectedIndex {
    final String location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) {
        return i;
      }
    }
    return 0; // Default is home
  }

  bool _isFabOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          !PlatformUtils.useDesktopUI(context) ? _buildNavBar() : null,
      body: Row(
        children: [
          if (PlatformUtils.useDesktopUI(context)) _buildNavRail(),
          Expanded(child: Center(child: widget.child)),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: !PlatformUtils.useDesktopUI(context) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 0),
        child:
            !PlatformUtils.useDesktopUI(context)
                ? _buildFloatingActionButton()
                : const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Use immediate animator to remove default animations
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
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
          icon: ProfilePicture(size: 12),
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
          icon: ProfilePicture(size: 12),
          label: const Text('You'),
          padding: const EdgeInsets.symmetric(vertical: 6.0),
        ),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
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
    context.go(_routes[index]);
  }
}
