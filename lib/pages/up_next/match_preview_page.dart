import 'package:beariscope/components/team_card.dart';
import 'package:beariscope/models/drive_team_note.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/drive_team_notes_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:libkoala/providers/permissions_provider.dart';
import 'package:libkoala/providers/user_profile_provider.dart';

final matchProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  matchKey,
) {
  return ref
      .watch(honeycombClientProvider)
      .get<Map<String, dynamic>>(
        '/matches?match=$matchKey',
        cachePolicy: CachePolicy.cacheFirst,
      );
});

class DriveTeamMatchPreviewPage extends ConsumerStatefulWidget {
  final String matchKey;

  const DriveTeamMatchPreviewPage({super.key, required this.matchKey});

  @override
  ConsumerState<DriveTeamMatchPreviewPage> createState() =>
      _DriveTeamMatchPreviewPageState();
}

class _DriveTeamMatchPreviewPageState
    extends ConsumerState<DriveTeamMatchPreviewPage> {
  final ValueNotifier<double> _currentPageNotifier = ValueNotifier(0.0);
  PageController? _pageController;

  @override
  void dispose() {
    _pageController?.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  void _updatePageController(double fraction, int initialPage) {
    if (_pageController != null &&
        (_pageController!.viewportFraction - fraction).abs() < 0.001) {
      return;
    }
    _pageController?.dispose();
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: fraction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = matchProvider(widget.matchKey);
    final matchAsync = ref.watch(requestProvider);
    final permissionChecker = ref.watch(permissionCheckerProvider);

    return matchAsync.when(
      loading:
          () => Scaffold(
            appBar: AppBar(title: Text('Match ${widget.matchKey}')),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Scaffold(
            appBar: AppBar(title: Text('Match ${widget.matchKey}')),
            body: Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(requestProvider),
                child: const Text('Retry'),
              ),
            ),
          ),
      data: (data) {
        String teamNumberFromKey(String teamKey) {
          return teamKey.replaceFirst(RegExp('^frc'), '');
        }

        bool containsTeam(List<String> teamKeys, String teamNumber) {
          return teamKeys.any(
            (teamKey) => teamNumberFromKey(teamKey) == teamNumber,
          );
        }

        final match = Map<String, dynamic>.from(data);
        final alliances = match['alliances'];
        final redTeams =
            alliances is Map && alliances['red'] is Map
                ? (alliances['red']['team_keys'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    const <String>[]
                : const <String>[];
        final blueTeams =
            alliances is Map && alliances['blue'] is Map
                ? (alliances['blue']['team_keys'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    const <String>[]
                : const <String>[];
        final cards = [
          ...redTeams.map((teamKey) {
            final number = teamNumberFromKey(teamKey);
            if (number.isEmpty) {
              return [teamKey, teamKey];
            }
            return ['Team $number', number];
          }),
          ...blueTeams.map((teamKey) {
            final number = teamNumberFromKey(teamKey);
            if (number.isEmpty) {
              return [teamKey, teamKey];
            }
            return ['Team $number', number];
          }),
        ];
        final compLevel = match['comp_level']?.toString() ?? '';
        final matchNumber = match['match_number'];
        final number =
            matchNumber is int
                ? matchNumber
                : int.tryParse(matchNumber?.toString() ?? '');
        final matchTitle =
            compLevel.isEmpty || number == null
                ? 'Match ${widget.matchKey}'
                : '${switch (compLevel) {
                  'qm' => 'Qualification Match',
                  'sf' => 'Semifinal Match',
                  'f' => 'Final Match',
                  _ => compLevel.toUpperCase(),
                }} $number';

        return Scaffold(
          appBar: AppBar(title: Text(matchTitle)),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (cards.isEmpty) {
                return const Center(child: Text('No teams available.'));
              }

              final width = constraints.maxWidth;

              final cardWidth = (width - 16).clamp(0.0, 600.0);
              final fraction =
                  width > 0 ? (cardWidth / width).clamp(0.0, 1.0) : 1.0;

              final stride = width * fraction;
              final contentLeftEdge = (width - cardWidth) / 2.0 + 8.0;

              _updatePageController(
                fraction,
                _currentPageNotifier.value.round().clamp(0, cards.length - 1),
              );

              final labelStyle = Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              );

              return Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _currentPageNotifier,
                      builder: (context, page, _) {
                        return Stack(
                          children: [
                            if (redTeams.isNotEmpty)
                              _buildStickyLabel(
                                context: context,
                                label: 'Red Alliance',
                                groupStartIndex: 0,
                                groupEndIndex: redTeams.length - 1,
                                page: page,
                                stride: stride,
                                cardWidth: cardWidth,
                                baseOffset: contentLeftEdge,
                                style: labelStyle,
                              ),
                            if (blueTeams.isNotEmpty)
                              _buildStickyLabel(
                                context: context,
                                label: 'Blue Alliance',
                                groupStartIndex: redTeams.length,
                                groupEndIndex:
                                    redTeams.length + blueTeams.length - 1,
                                page: page,
                                stride: stride,
                                cardWidth: cardWidth,
                                baseOffset: contentLeftEdge,
                                style: labelStyle,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification &&
                            _pageController?.hasClients == true) {
                          _currentPageNotifier.value =
                              _pageController?.page ?? 0.0;
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TeamCard(teamKey: cards[index][1]),
                          );
                        },
                      ),
                    ),
                  ),

                  if (cards.length > 1)
                    ValueListenableBuilder<double>(
                      valueListenable: _currentPageNotifier,
                      builder: (context, page, _) {
                        return DotsIndicator(
                          dotsCount: cards.length,
                          position: page.clamp(0, cards.length - 1).toDouble(),
                          onTap: (position) {
                            _pageController?.animateToPage(
                              position.toInt(),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                          decorator: DotsDecorator(
                            activeColor: Theme.of(context).colorScheme.primary,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                            spacing: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            size: const Size.square(8.0),
                            activeSize: const Size(24.0, 8.0),
                            activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        );
                      },
                    ),
                  if (permissionChecker?.hasPermission(
                        PermissionKey.driveTeamUpload,
                      ) ??
                      false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: 586,
                        child: FilledButton(
                          onPressed: () {
                            final is2046OnRed = containsTeam(redTeams, '2046');
                            final is2046OnBlue = containsTeam(
                              blueTeams,
                              '2046',
                            );
                            final allianceTeams =
                                is2046OnRed
                                    ? redTeams
                                    : is2046OnBlue
                                    ? blueTeams
                                    : const <String>[];
                            final memberKeys =
                                allianceTeams
                                    .where(
                                      (k) => teamNumberFromKey(k) != '2046',
                                    )
                                    .toList();
                            final allianceLabel =
                                is2046OnRed ? 'Red Alliance' : 'Blue Alliance';
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder:
                                  (context) => _DriveTeamNotesSheet(
                                    matchKey: widget.matchKey,
                                    allianceMemberTeamKeys: memberKeys,
                                    allianceLabel: allianceLabel,
                                  ),
                            );
                          },
                          child: const Text('Take Notes'),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStickyLabel({
    required BuildContext context,
    required String label,
    required int groupStartIndex,
    required int groupEndIndex,
    required double page,
    required double stride,
    required double cardWidth,
    required double baseOffset,
    required TextStyle? style,
  }) {
    final double boxLeft = baseOffset + (groupStartIndex - page) * stride;
    final double boxRight =
        baseOffset + (groupEndIndex - page) * stride + cardWidth - 16;

    const double stickyTarget = 16.0;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
    )..layout();

    final double labelWidth = textPainter.width;

    double x = boxLeft;

    if (x < stickyTarget) {
      x = stickyTarget;
    }

    if (x + labelWidth > boxRight) {
      x = boxRight - labelWidth;
    }

    return Positioned(left: x, child: Text(label, style: style));
  }
}

class _DriveTeamNotesSheet extends ConsumerStatefulWidget {
  final String matchKey;
  final List<String> allianceMemberTeamKeys;
  final String allianceLabel;

  const _DriveTeamNotesSheet({
    required this.matchKey,
    required this.allianceMemberTeamKeys,
    required this.allianceLabel,
  });

  @override
  ConsumerState<_DriveTeamNotesSheet> createState() =>
      _DriveTeamNotesSheetState();
}

class _DriveTeamNotesSheetState extends ConsumerState<_DriveTeamNotesSheet> {
  final Map<String, TextEditingController> _controllers = {};

  final Map<String, String> _existingIds = {};

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  //populates the controllers with existing notes
  void _initControllers(Map<int, DriveTeamNote> existingNotes) {
    if (_initialized) return;
    _initialized = true;

    for (final teamKey in widget.allianceMemberTeamKeys) {
      final teamNumber = teamKey.replaceFirst(RegExp(r'^frc'), '');
      final teamNum = int.tryParse(teamNumber);
      final controller = TextEditingController();

      if (teamNum != null && existingNotes.containsKey(teamNum)) {
        final existing = existingNotes[teamNum]!;
        controller.text = existing.note;
        if (existing.id != null && existing.id!.isNotEmpty) {
          _existingIds[teamNumber] = existing.id!;
        }
      }

      _controllers[teamNumber] = controller;
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final userInfo = ref.read(userInfoProvider).asData?.value;
      final authMe = await ref.read(authMeProvider.future);
      final eventKey = ref.read(currentEventProvider);

      final scoutedBy = userInfo?.name?.trim() ?? 'Unknown User';
      final userId = authMe?.user.id ?? '';

      final entries = <Map<String, Object?>>[];
      for (final entry in _controllers.entries) {
        final text = entry.value.text.trim();
        if (text.isEmpty) continue;
        final teamNum = int.tryParse(entry.key) ?? 0;
        final note = DriveTeamNote(
          id: _existingIds[entry.key],
          matchKey: widget.matchKey,
          teamNumber: teamNum,
          note: text,
          scoutedBy: scoutedBy,
          userId: userId,
          eventKey: eventKey,
          season: 2026,
        );
        entries.add(note.toIngestEntry());
      }

      if (entries.isNotEmpty) {
        final client = ref.read(honeycombClientProvider);
        await client.post('/scout/ingest', data: {'entries': entries});
        // sync the local Hive cache so notes survive a page-exit and re-entry.
        await ref.read(scoutingDataProvider.notifier).refresh();
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save notes: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(myDriveTeamNotesProvider(widget.matchKey));
    final theme = Theme.of(context);

    return notesAsync.when(
      loading:
          () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => SizedBox(
            height: 200,
            child: Center(child: Text('Error loading notes: $e')),
          ),
      data: (existingNotes) {
        _initControllers(existingNotes);

        if (widget.allianceMemberTeamKeys.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('Cannot load notes — 2046 not found in this match.'),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.allianceLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                for (final teamKey in widget.allianceMemberTeamKeys) ...[
                  Builder(
                    builder: (context) {
                      final teamNumber = teamKey.replaceFirst(
                        RegExp(r'^frc'),
                        '',
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            teamNumber.isEmpty ? teamKey : teamNumber,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controllers[teamNumber],
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Notes',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Save Notes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
