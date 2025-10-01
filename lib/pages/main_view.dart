import 'package:beariscope/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:beariscope/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Main shell view with adaptive navigation drawer and FAB.
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

  const _NavItem(this.route, this.icon, this.label, this.group);
}

class _MainViewState extends State<MainView> {
  static const double _drawerWidth = 280;
  static const _animationDuration = Duration(milliseconds: 100);

  static const List<_NavItem> _navItems = [
    _NavItem('/home', Symbols.home_rounded, 'Home', 'General'),
    _NavItem('/event', Symbols.event_rounded, 'Event', 'General'),
    _NavItem(
      '/team_lookup',
      Symbols.smart_toy_rounded,
      'Team Lookup',
      'Insights',
    ),
    _NavItem(
      '/predictions',
      Symbols.batch_prediction_rounded,
      'Predictions',
      'Insights',
    ),
    _NavItem('/picklists', Symbols.list_alt_rounded, 'Picklists', 'Insights'),
    _NavItem(
      '/corrections',
      Symbols.table_edit_rounded,
      'Data Corrections',
      'Scouting',
    ),
    _NavItem(
      '/ui_creator',
      Symbols.dashboard_customize_rounded,
      'UI Creator',
      'Scouting',
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
    final body =
        isDesktop
            ? Row(
              children: [
                navigationDrawer,
                Expanded(child: SafeArea(child: widget.child)),
              ],
            )
            : SafeArea(child: widget.child);

    return Scaffold(
      key: _scaffoldKey,
      appBar:
          !isDesktop
              ? AppBar(
                leading: IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              )
              : null,
      drawer: !isDesktop ? navigationDrawer : null,
      drawerEnableOpenDragGesture: !isDesktop,
      drawerBarrierDismissible: !isDesktop,
      body: body,
    );
  }

  List<Widget> _buildNavChildren() {
    final children = <Widget>[];

    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
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
            Text(
              'Beariscope',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );

    children.add(
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 28),
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
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 28),
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
