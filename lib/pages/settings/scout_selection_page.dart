import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

class CurrentScout extends Notifier<String> {
  @override
  String build() => 'None';

  void newScout(String scout) => state = scout;
}

class ScoutSelectionPage extends ConsumerStatefulWidget {
  const ScoutSelectionPage({super.key});

  @override
  ConsumerState<ScoutSelectionPage> createState() => _ScoutSelectionPageState();
}

class _ScoutSelectionPageState extends ConsumerState<ScoutSelectionPage> {
  final TextEditingController _searchTEC = TextEditingController();
  final TextEditingController _addScoutTEC = TextEditingController();
  final TextEditingController newNameTEC = TextEditingController();
  final _scoutsProvider = getListDataProvider(
    endpoint: '/scouts',
    forceRefresh: true,
  );

  @override
  void initState() {
    super.initState();
    _searchTEC.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchTEC.dispose();
    _addScoutTEC.dispose();
    newNameTEC.dispose();
    super.dispose();
  }

  List<Widget> buildScoutList(List<Map<String, String>> scouts) {
    return scouts.map((scout) {
      final name = scout["name"]!;
      final id = scout["uuid"]!;

      return BeariscopeCard(
        title: name,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: IconButton(
                onPressed: () async {
                  newNameTEC.clear();
                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Rename Scout'),
                          content: TextField(
                            controller: newNameTEC,
                            decoration: const InputDecoration(
                              labelText: 'New name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (newNameTEC.text.isNotEmpty) {
                                  await ref
                                      .read(honeycombClientProvider)
                                      .put(
                                        '/scouts/$id',
                                        data: {"name": newNameTEC.text},
                                      );
                                  ref.invalidate(_scoutsProvider);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: const Text('Rename'),
                            ),
                          ],
                        ),
                  );
                },
                icon: Icon(
                  Icons.edit_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: IconButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Scout'),
                          content: const Text(
                            'Are you sure you want to delete this scout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(honeycombClientProvider)
                        .delete('/scouts/$id');
                    ref.invalidate(_scoutsProvider);
                  }
                },
                icon: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scoutsAsync = ref.watch(_scoutsProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(controller: _searchTEC, hintText: 'Search Scouts'),
        actions: [SizedBox(width: 48)],
      ),
      body: scoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(_scoutsProvider),
                child: const Text('Retry'),
              ),
            ),
        data: (data) {
          final scoutData =
              data.map((item) {
                  return {
                    "name": item["name"] as String,
                    "uuid": item["uuid"] as String,
                  };
                }).toList()
                ..sort((a, b) => a["name"]!.compareTo(b["name"]!));

          final filteredScouts =
              scoutData
                  .where(
                    (scout) => scout["name"]!.toLowerCase().contains(
                      _searchTEC.text.toLowerCase(),
                    ),
                  )
                  .toList();

          return BeariscopeCardList(children: buildScoutList(filteredScouts));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _addScoutTEC.clear();
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Add Scout'),
                  content: TextField(
                    controller: _addScoutTEC,
                    decoration: const InputDecoration(labelText: 'Scout name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_addScoutTEC.text.isNotEmpty) {
                          await ref
                              .read(honeycombClientProvider)
                              .post(
                                '/scouts',
                                data: {"name": _addScoutTEC.text},
                              );
                          ref.invalidate(_scoutsProvider);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          );
        },
        tooltip: 'Add Scout',
        child: const Icon(Icons.add),
      ),
    );
  }
}
