import 'package:beariscope/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/ui/widgets/profile_picture.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainView extends StatefulWidget {
  final Widget child;

  const MainView({super.key, required this.child});

  @override
  State<MainView> createState() => _MainViewState();
}

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  final String group;

  const _NavItem({
    required this.route,
    required this.icon,
    required this.label,
    required this.group,
  });
}

class MainViewController extends InheritedWidget {
  final VoidCallback openDrawer;
  final bool isDesktop;

  const MainViewController({
    super.key,
    required this.openDrawer,
    required this.isDesktop,
    required super.child,
  });

  static MainViewController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainViewController>()!;

  @override
  bool updateShouldNotify(MainViewController oldWidget) =>
      isDesktop != oldWidget.isDesktop;
}

class _MainViewState extends State<MainView> {
  static const double _drawerWidth = 280;
  static const _animationDuration = Duration(milliseconds: 100);

  static const List<_NavItem> _navItems = [
    _NavItem(
      route: '/home',
      icon: Symbols.home_rounded,
      label: 'Home',
      group: 'General',
    ),
    _NavItem(
      route: '/event',
      icon: Symbols.event_rounded,
      label: 'Event',
      group: 'General',
    ),
    _NavItem(
      route: '/team_lookup',
      icon: Symbols.smart_toy_rounded,
      label: 'Team Lookup',
      group: 'Insights',
    ),
    _NavItem(
      route: '/predictions',
      icon: Symbols.batch_prediction_rounded,
      label: 'Predictions',
      group: 'Insights',
    ),
    _NavItem(
      route: '/picklists',
      icon: Symbols.list_alt_rounded,
      label: 'Picklists',
      group: 'Insights',
    ),
    _NavItem(
      route: '/corrections',
      icon: Symbols.table_edit_rounded,
      label: 'Data Corrections',
      group: 'Scouting',
    ),
    _NavItem(
      route: '/ui_creator',
      icon: Symbols.dashboard_customize_rounded,
      label: 'UI Creator',
      group: 'Scouting',
    ),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _selectedIndex {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _navItems.indexWhere((n) => location.startsWith(n.route));
    return idx < 0 ? 0 : idx;
  }

  void _onDestinationSelected(int index, bool isDesktop) {
    if (index == _selectedIndex) {
      if (!isDesktop) Navigator.pop(context);
      return;
    }
    context.go(_navItems[index].route);
    if (!isDesktop) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = PlatformUtils.useDesktopUI(context);

    final navigationDrawer = SizedBox(
      width: _drawerWidth,
      child: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => _onDestinationSelected(i, isDesktop),
        children: _buildNavChildren(),
      ),
    );

    final childContent =
        isDesktop
            ? Row(children: [navigationDrawer, Expanded(child: widget.child)])
            : widget.child;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : navigationDrawer,
      drawerEnableOpenDragGesture: !isDesktop,
      drawerBarrierDismissible: !isDesktop,
      body: MainViewController(
        isDesktop: isDesktop,
        openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        child: childContent,
      ),
    );
  }

  List<Widget> _buildNavChildren() {
    final children = <Widget>[];

    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 24, 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/scuffed_logo.svg',
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcATop,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Beariscope',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: 'Settings',
              child: InkWell(
                onTap: () => context.push('/settings'),
                borderRadius: BorderRadius.circular(24),
                child: ProfilePicture(size: 16),
              ),
            ),
          ],
        ),
      ),
    );

    children.add(
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 28),
        child: Divider(),
      ),
    );

    String? currentGroup;
    for (final entry in _navItems.indexed) {
      final index = entry.$1;
      final item = entry.$2;
      if (item.group != currentGroup) {
        if (currentGroup != null) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Divider(),
            ),
          );
        }
        currentGroup = item.group;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 10, 16, 16),
            child: Text(
              currentGroup,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      }
      children.add(
        NavigationDrawerDestination(
          icon: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: _selectedIndex == index ? 0.0 : 1.0,
              end: _selectedIndex == index ? 1.0 : 0.0,
            ),
            duration: _animationDuration,
            curve: Curves.fastOutSlowIn,
            builder:
                (context, value, _) =>
                    Icon(item.icon, weight: 600, fill: value),
          ),
          label: Text(item.label),
        ),
      );
    }

    return children;
  }
}
