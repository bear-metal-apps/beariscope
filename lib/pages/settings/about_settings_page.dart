import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutSettingsPage extends ConsumerStatefulWidget {
  const AboutSettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AboutSettingsPageState();
  }
}

class AboutSettingsPageState extends ConsumerState<AboutSettingsPage> {
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(style: TextStyle(fontSize: 30), 'About Bear Metal'),
              Padding(
                padding: EdgeInsets.all(20),
                child: Image(
                  image: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGsrfomCbhbrN0fotdpuRs-1Yrb0fvKw_lxA&s',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    style: TextStyle(fontSize: 14),
                    'Bear Metal is a FIRST Robotics Competition team. We are the official Robotics team for Tahoma High School. Our Robotics team consists of several specialized sub-teams which all contribute to our success: Design, Fabrication, Hardware, Programming, Business, Apps, and Systems Engineering. Aside from our sub-teams, our coaches, executives, and mentors are crucial in managing, organizing, and supporting out Robotics team.',
                  ),
                ),
              ),
              Text(style: TextStyle(fontSize: 30), 'About Beariscope'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    style: TextStyle(fontSize: 14),
                    'Also known as the Viewer App, Beariscope is an organized method for our Robotics team members to view, sort, synthesize, and analyze data gathered by our Scouting Team. Features include picklists, which prioritize certain teams for use during alliance selection, team databases, which store information on a team\'s statistics on scouted games within a given season, and scheduling, in which team members can view upcoming tasks and events. \n'
                    'Beariscope is coded by the Apps subteam of Bear Metal. The language used to code Beariscope is Dart, using Flutter as the app building software. The APIs used in Beariscope are listed below: \n'
                    ' - The Blue Alliance | https://www.thebluealliance.com/apidocs \n'
                    ' - Statbotics | https://www.statbotics.io/docs/rest \n'
                    ' - FRC Nexus | https://frc.nexus/api/v1/docs',
                  ),
                ),
              ),
              Text(
                style: TextStyle(fontSize: 30),
                'About the Bear Metal Apps Subteam',
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Image(
                  image: NetworkImage(
                    'https://avatars.githubusercontent.com/u/149735106?s=200&v=4',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    style: TextStyle(fontSize: 14),
                    'All Apps subteam team members: \n'
                    ' - Bradshaw, Callie "Sen" \n'
                    ' - Dodge, Benton "Ben" \n'
                    ' - Gupta, Aarav \n'
                    ' - Hayes, Ashton "Ash" \n'
                    ' - Jorgensen, Jack \n'
                    ' - Libadisos, Jacob "Tiny" \n'
                    ' - Sojy, Meghnaa \n'
                    ' - Tice, Zayden \n'
                    ' - Yeo, Ryan \n'
                    'This is the official Bear Metal 2046 Apps subteam GitHub organization: \n'
                    ' - https://github.com/bear-metal-apps',
                  ),
                ),
              ),
              SizedBox(height: 35),
              Text(
                style: TextStyle(fontSize: 10),
                'Beariscope Version: ${packageInfo.version}',
              ),
              Text(
                style: TextStyle(fontSize: 10),
                'Copyright Bear Metal 2046, 2025. All rights reserved.',
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
