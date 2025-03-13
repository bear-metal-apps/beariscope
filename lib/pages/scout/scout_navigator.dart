import 'package:flutter/material.dart';
import 'scout_page.dart';

class ScoutNavigator extends StatelessWidget {
  const ScoutNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/scout',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/scout':
            builder = (BuildContext _) => const ScoutPage();
            break;
        // Add additional nested routes here if needed.
          default:
            builder = (BuildContext _) => const ScoutPage();
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}