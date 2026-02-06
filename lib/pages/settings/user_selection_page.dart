import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:riverpod/src/framework.dart';

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
  final usersProvider = FutureProvider<List<dynamic>>((ref) async {
    final client = ref.watch(honeycombClientProvider);
    return client.get<List<dynamic>>('/scouts');
  });

  List<Widget> buildUserList(List<String> users) {
    List<Widget> userList = [];

    for (var i = 0; i < users.length; i++) {
      userList.add(UserSelectionNameCard(userName: users[i]));
    }

    return userList;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    // final usersProvider = getDataProvider(endpoint: '/scouts');
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
              onPressed: () {},
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
              usersAsync.when(
                data: (data) {
                  final userData =
                      data.map((item) => item['name'] as String).toList();
                  return Column(children: buildUserList(userData));
                },
                error:
                    (err, stack) => FilledButton(
                      onPressed:
                          () =>
                              ref.invalidate(usersProvider as ProviderOrFamily),
                      child: const Text('Retry'),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
