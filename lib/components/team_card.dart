import 'package:animations/animations.dart'; // Import this package
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/device_info_provider.dart';

class TeamCard extends StatelessWidget {
  final String teamName;
  final String teamNumber;
  final double? height;

  const TeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      useRootNavigator: true,
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0,

      openColor: Theme.of(context).scaffoldBackgroundColor,
      middleColor: Theme.of(context).scaffoldBackgroundColor,
      closedColor: Theme.of(context).colorScheme.surfaceContainer,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedBuilder: (context, action) {
        return SizedBox(
          height: height ?? 256,
          width: double.infinity,
          child: InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 52,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Xolonium',
                        ),
                      ),
                      Text(
                        teamNumber,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return TeamDetailsPage(teamName: teamName, teamNumber: teamNumber);
      },
    );
  }
}

class TeamDetailsPage extends ConsumerWidget {
  final String teamName;
  final String teamNumber;

  const TeamDetailsPage({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4, // how many tabs
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text('$teamName - $teamNumber'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Averages'),
                  Tab(text: 'Breakdown'),
                  Tab(text: 'Notes'),
                  Tab(text: 'Capabilities'),
                ],
              ),
            ),

            body: const TabBarView(
              children: [
                Center(child: Text('Averages content')),
                Center(child: Text('Breakdown content')),
                Center(child: Text('Notes content')),
                Center(child: Text('Capabilities content')),
              ],
            ),
          ),
          if (ref.read(deviceInfoProvider).deviceOS == DeviceOS.ios)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
