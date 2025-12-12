import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  final String teamName;
  final String teamNumber;

  const TeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // changes mouse to pointer when it's hovering over the card
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias, // makes sure InkWell ripple stays inside card
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailsPage(
                  teamNumber: teamNumber,
                  teamName: teamName,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // profile icon
                const Icon(
                  Icons.account_circle,
                  size: 48,
                  color: Colors.grey,
                ),

                const SizedBox(width: 12),

                // team info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      teamNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeamDetailsPage extends StatelessWidget {
  final String teamName;
  final String teamNumber;

  const TeamDetailsPage({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // how many tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Team $teamNumber'),
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
    );
  }
}






