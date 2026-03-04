import 'dart:convert';

import 'package:beariscope/components/beariscope_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:libkoala/providers/permissions_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  List<Map<String, String>>? _optimisticScouts;
  final _scoutsProvider = FutureProvider<List<dynamic>>((ref) {
    return ref
        .watch(honeycombClientProvider)
        .get<List<dynamic>>('/scouts', cachePolicy: CachePolicy.cacheFirst);
  });

  List<Map<String, String>> _normalizeScouts(List<dynamic> data) {
    final scouts =
        data.map((item) {
            return {
              "name": item["name"] as String,
              "uuid": item["uuid"] as String,
            };
          }).toList()
          ..sort((a, b) => a["name"]!.compareTo(b["name"]!));
    return scouts;
  }

  Future<void> _refreshScouts() async {
    final client = ref.read(honeycombClientProvider);
    client.invalidateCache('/scouts');
    ref.invalidate(_scoutsProvider);
    try {
      await ref.read(_scoutsProvider.future);
      if (mounted) {
        setState(() => _optimisticScouts = null);
      }
    } catch (_) {
      // Keep existing optimistic/cached state if refresh fails.
    }
  }

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
    final permissionChecker = ref.read(permissionCheckerProvider);
    final canManageScouts =
        permissionChecker?.hasPermission(PermissionKey.scoutsManage) ?? false;

    return scouts.map((scout) {
      final name = scout["name"]!;
      final id = scout["uuid"]!;

      return BeariscopeCard(
        title: name,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canManageScouts)
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
                                border: OutlineInputBorder(),
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
                                    final previous =
                                        List<Map<String, String>>.from(
                                          _optimisticScouts ??
                                              _normalizeScouts(
                                                ref
                                                        .read(_scoutsProvider)
                                                        .asData
                                                        ?.value ??
                                                    const [],
                                              ),
                                        );

                                    setState(() {
                                      _optimisticScouts =
                                          previous
                                              .map(
                                                (entry) =>
                                                    entry['uuid'] == id
                                                        ? {
                                                          'name':
                                                              newNameTEC.text,
                                                          'uuid': id,
                                                        }
                                                        : entry,
                                              )
                                              .toList()
                                            ..sort(
                                              (a, b) => a['name']!.compareTo(
                                                b['name']!,
                                              ),
                                            );
                                    });

                                    try {
                                      await ref
                                          .read(honeycombClientProvider)
                                          .put(
                                            '/scouts/$id',
                                            data: {"name": newNameTEC.text},
                                          );
                                      await _refreshScouts();
                                      if (mounted) {
                                        Navigator.of(this.context).pop();
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(
                                          () => _optimisticScouts = previous,
                                        );
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to rename scout: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text('Rename'),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: Icon(Symbols.edit_rounded),
                ),
              ),
            if (canManageScouts)
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
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
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
                      final previous = List<Map<String, String>>.from(
                        _optimisticScouts ??
                            _normalizeScouts(
                              ref.read(_scoutsProvider).asData?.value ??
                                  const [],
                            ),
                      );
                      setState(() {
                        _optimisticScouts =
                            previous
                                .where((entry) => entry['uuid'] != id)
                                .toList();
                      });

                      try {
                        await ref
                            .read(honeycombClientProvider)
                            .delete('/scouts/$id');
                        await _refreshScouts();
                      } catch (e) {
                        if (mounted) {
                          setState(() => _optimisticScouts = previous);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete scout: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: Icon(Symbols.delete_rounded),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  List<String> _parseCsvNames(String input) {
    final normalized = input.replaceAll(RegExp(r',\s+'), ',');
    return normalized
        .split(RegExp(r'[\r\n,]+'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<void> _importFromCsv() async {
    final result = await showDialog<_CsvImportResult>(
      context: context,
      builder: (context) => const _CsvImportDialog(),
    );

    if (!mounted || result == null) return;

    final names = _parseCsvNames(result.csvText);
    if (names.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No names found in CSV.')));
      return;
    }

    for (final name in names) {
      await ref
          .read(honeycombClientProvider)
          .post('/scouts', data: {"name": name});
    }

    await _refreshScouts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Imported ${names.length} scouts.')));
  }

  @override
  Widget build(BuildContext context) {
    final scoutsAsync = ref.watch(_scoutsProvider);
    final permissionChecker = ref.watch(permissionCheckerProvider);
    final canManageScouts =
        permissionChecker?.hasPermission(PermissionKey.scoutsManage) ?? false;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: _searchTEC,
          elevation: WidgetStateProperty.all(0.0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: Icon(Symbols.search_rounded),
          hintText: 'Search scouts',
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 8.0),
        actions: [
          if (canManageScouts)
            PopupMenuButton(
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Symbols.file_upload_rounded),
                          const SizedBox(width: 8),
                          const Text('Import From CSV'),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                if (value == 'import') {
                  _importFromCsv();
                }
              },
            )
          else
            SizedBox(width: 48),
        ],
      ),
      body: scoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: FilledButton(
                onPressed: _refreshScouts,
                child: const Text('Retry'),
              ),
            ),
        data: (data) {
          final scoutData = _normalizeScouts(data);
          final source = _optimisticScouts ?? scoutData;

          final filteredScouts =
              source
                  .where(
                    (scout) => scout["name"]!.toLowerCase().contains(
                      _searchTEC.text.toLowerCase(),
                    ),
                  )
                  .toList();

          return RefreshIndicator(
            onRefresh: _refreshScouts,
            child: BeariscopeCardList(children: buildScoutList(filteredScouts)),
          );
        },
      ),
      floatingActionButton:
          canManageScouts
              ? FloatingActionButton(
                onPressed: () async {
                  _addScoutTEC.clear();
                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Add Scout'),
                          content: TextField(
                            controller: _addScoutTEC,
                            decoration: const InputDecoration(
                              labelText: 'Scout name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (_addScoutTEC.text.isNotEmpty) {
                                  final previous =
                                      List<Map<String, String>>.from(
                                        _optimisticScouts ??
                                            _normalizeScouts(
                                              ref
                                                      .read(_scoutsProvider)
                                                      .asData
                                                      ?.value ??
                                                  const [],
                                            ),
                                      );
                                  setState(() {
                                    _optimisticScouts = [
                                      ...previous,
                                      {
                                        'name': _addScoutTEC.text,
                                        'uuid':
                                            'temp-${DateTime.now().microsecondsSinceEpoch}',
                                      },
                                    ]..sort(
                                      (a, b) =>
                                          a['name']!.compareTo(b['name']!),
                                    );
                                  });

                                  try {
                                    await ref
                                        .read(honeycombClientProvider)
                                        .post(
                                          '/scouts',
                                          data: {"name": _addScoutTEC.text},
                                        );
                                    await _refreshScouts();
                                    if (mounted) {
                                      Navigator.of(this.context).pop();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      setState(
                                        () => _optimisticScouts = previous,
                                      );
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add scout: $e',
                                          ),
                                        ),
                                      );
                                    }
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
                child: const Icon(Symbols.add),
              )
              : null,
    );
  }
}

enum _CsvImportMode { file, paste }

class _CsvImportResult {
  const _CsvImportResult(this.csvText);

  final String csvText;
}

class _CsvImportDialog extends StatefulWidget {
  const _CsvImportDialog();

  @override
  State<_CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<_CsvImportDialog> {
  _CsvImportMode _mode = _CsvImportMode.file;
  PlatformFile? _selectedFile;
  String? _fileContents;
  final TextEditingController _pasteController = TextEditingController();

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select CSV',
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read file contents.')),
      );
      return;
    }

    setState(() {
      _selectedFile = file;
      _fileContents = utf8.decode(bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final canImport =
        _mode == _CsvImportMode.file
            ? (_fileContents?.trim().isNotEmpty ?? false)
            : _pasteController.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Import From CSV'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<_CsvImportMode>(
            segments: const [
              ButtonSegment<_CsvImportMode>(
                value: _CsvImportMode.file,
                label: Text('File'),
              ),
              ButtonSegment<_CsvImportMode>(
                value: _CsvImportMode.paste,
                label: Text('Paste'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
            },
          ),
          const SizedBox(height: 16),
          if (_mode == _CsvImportMode.file) ...[
            const Text('Upload a CSV file from your device'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Symbols.upload_file_rounded),
              label: const Text('Select file'),
              onPressed: _pickFile,
            ),
            const SizedBox(height: 8),
            if (_selectedFile != null)
              Text(
                _selectedFile!.name,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
          ] else ...[
            const Text('Paste a comma-separated list of scout names'),
            const SizedBox(height: 12),
            TextField(
              controller: _pasteController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'John Scout,Jane Scout',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed:
              canImport
                  ? () {
                    final csvText =
                        _mode == _CsvImportMode.file
                            ? _fileContents ?? ''
                            : _pasteController.text;
                    Navigator.of(context).pop(_CsvImportResult(csvText));
                  }
                  : null,
          child: const Text('Import'),
        ),
      ],
    );
  }
}
