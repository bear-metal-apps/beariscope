import 'package:flutter/material.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  List<Widget> users = [];
  final TextEditingController _newUserTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: _newUserTEC,
          hintText: 'Type Your Name Here',
          trailing: [
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add User',
              onPressed: () {
                setState(() {
                  users.add(UserSelectionNameCard(userName: _newUserTEC.text));
                });
              },
            )
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: users,
          ),
        ),
      ),
    );
  }
}

class UserSelectionNameCard extends StatefulWidget {
  final String userName;
  final double? height;

  const UserSelectionNameCard({super.key, required this.userName, this.height});
  @override
  State<UserSelectionNameCard> createState() => _UserSelectionNameCardState();
}

class _UserSelectionNameCardState extends State<UserSelectionNameCard> {
  bool scouted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () async {},
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: widget.height ?? 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}