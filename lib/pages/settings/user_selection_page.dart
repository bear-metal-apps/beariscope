import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

// Widget preparation
class UserSelectionNameCard extends ConsumerStatefulWidget {
  final String userName;
  final double? height;
  final Future<void> Function()? editFunction;
  final Future<void> Function()? deleteFunction;

  const UserSelectionNameCard({
    super.key,
    required this.userName,
    this.height,
    this.editFunction,
    this.deleteFunction,
  });
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
                      onPressed: () async {
                        await widget.editFunction!();
                      },
                      child: Text('Rename'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: FilledButton(
                      onPressed: () async {
                        await widget.deleteFunction!();
                      },
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

class RenamePage extends ConsumerStatefulWidget {
  final Future<void> Function() renameFunction;
  final TextEditingController tEC;

  const RenamePage({
    super.key,
    required this.renameFunction,
    required this.tEC,
  });

  @override
  ConsumerState<RenamePage> createState() => _RenamePageState();
}

class _RenamePageState extends ConsumerState<RenamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rename User')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter new name',
                ),
                controller: widget.tEC,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (widget.tEC.text != '') {
                  await widget.renameFunction();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
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
  final TextEditingController newNameTEC = TextEditingController();
  final _usersProvider = getListDataProvider(
    endpoint: '/scouts',
    forceRefresh: true,
  );

  // Reloads the List<Card>
  List<Widget> buildUserList(List<Map<String, String>> users) {
    return users.map((user) {
      // Pulls user values from users
      final name = user["name"]!;
      final id = user["uuid"]!;

      // Initializes for every user in users
      return UserSelectionNameCard(
        userName: name,
        editFunction: () async {
          newNameTEC.clear();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RenamePage(
                    renameFunction: () async {
                      await ref
                          .read(honeycombClientProvider)
                          .put('/scouts/$id', data: {"name": newNameTEC.text});
                      ref.invalidate(_usersProvider);
                    },
                    tEC: newNameTEC,
                  ),
            ),
          );
        },
        deleteFunction: () async {
          await ref.read(honeycombClientProvider).delete('/scouts/$id');
          ref.invalidate(_usersProvider);
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final usersAsync = ref.watch(_usersProvider);
    return Scaffold(
      // Page input
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
                    .read(honeycombClientProvider)
                    .post('/scouts', data: {"name": _newUserTEC.text});
                ref.invalidate(_usersProvider);
              },
            ),
          ],
        ),
      ),
      // Column of Widget
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) => FilledButton(
                      onPressed: () => ref.invalidate(_usersProvider),
                      child: const Text('Retry'),
                    ),
                data: (data) {
                  final userData =
                      data.map((item) {
                        return {
                          "name": item["name"] as String,
                          "uuid": item["uuid"] as String,
                        };
                      }).toList();
                  return Column(children: buildUserList(userData));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
