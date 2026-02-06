import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/libkoala.dart';


// Riverpod preparation
class User {
  String username;

  User(this.username);
}

// Widget preparation
class UserSelectionNameCard extends ConsumerStatefulWidget {
  final String userName;
  final double? height;

  const UserSelectionNameCard({super.key, required this.userName, this.height});
  @override
  ConsumerState<UserSelectionNameCard> createState() =>
      _UserSelectionNameCardState();
}

class _UserSelectionNameCardState extends ConsumerState<UserSelectionNameCard> {
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
            onTap: () {
              ref
                  .read(currentUserNotifierProvider.notifier)
                  .newUser(widget.userName);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: widget.height ?? 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(child: SizedBox(height: widget.height ?? 80)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: FilledButton(
                      onPressed: () {},
                      child: Text('Rename'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: FilledButton(
                      onPressed: () {},
                      child: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// NotifierProvider
class UserDatabase extends Notifier<List<User>> {
  @override
  List<User> build() => [];

  void addUser(User user) => state = [...state, user];
}

final usersNotifierProvider = NotifierProvider<UserDatabase, List<User>>(
  UserDatabase.new,
);

class CurrentUser extends Notifier<String> {
  @override
  String build() => 'None';

  void newUser(String user) => state = user;
}

final currentUserNotifierProvider = NotifierProvider<CurrentUser, String>(
  CurrentUser.new,
);

// Widget tree
class UserSelectionPage extends ConsumerStatefulWidget {
  const UserSelectionPage({super.key});

  @override
  ConsumerState<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends ConsumerState<UserSelectionPage> {
  final TextEditingController _newUserTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(usersNotifierProvider);
    final currentUser = ref.watch(currentUserNotifierProvider);
    final usersProvider = getDataProvider(
      endpoint: '/scouts'
    );
    final usersAsync = ref.watch(usersProvider);
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
                ref
                    .read(usersNotifierProvider.notifier)
                    .addUser(User(_newUserTEC.text));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('Current User: $currentUser'),
              ),
              ...allUsers.map(
                (u) => UserSelectionNameCard(userName: u.username),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
