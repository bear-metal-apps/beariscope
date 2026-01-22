import 'package:beariscope/components/team_card.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

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
    final matchProvider = getDataProvider(
      endpoint: '/matches?match=${widget.matchKey}',
    );
    final matchAsync = ref.watch(matchProvider);

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
                onPressed: () => ref.invalidate(matchProvider),
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
                            child: TeamCard(
                              teamName: cards[index][0],
                              teamNumber: cards[index][1],
                            ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: 586,
                      child: FilledButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (BuildContext context) {
                              final is2046OnRed = containsTeam(
                                redTeams,
                                '2046',
                              );
                              final is2046OnBlue = containsTeam(
                                blueTeams,
                                '2046',
                              );
                              final notesTeams =
                                  is2046OnRed
                                      ? redTeams
                                      : is2046OnBlue
                                      ? blueTeams
                                      : const <String>[];

                              return SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (notesTeams.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Text('Cannot load notes'),
                                        )
                                      else
                                        ...(() {
                                          final theme = Theme.of(context);
                                          final title =
                                              is2046OnRed
                                                  ? 'Red Alliance'
                                                  : 'Blue Alliance';
                                          final widgets = <Widget>[
                                            Text(
                                              title,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onSurface,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                          ];

                                          for (final teamKey in notesTeams) {
                                            if (teamNumberFromKey(teamKey) ==
                                                '2046') {
                                              continue;
                                            }
                                            final teamNumber =
                                                teamNumberFromKey(teamKey);
                                            widgets.addAll([
                                              Text(
                                                teamNumber.isEmpty
                                                    ? teamKey
                                                    : teamNumber,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              const TextField(
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Notes',
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ]);
                                          }

                                          return widgets;
                                        })(),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              );
                            },
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
