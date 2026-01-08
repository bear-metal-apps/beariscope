import 'package:beariscope/components/team_card.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class DriveTeamMatchPreviewPage extends StatefulWidget {
  final String matchId;

  const DriveTeamMatchPreviewPage({super.key, required this.matchId});

  @override
  State<DriveTeamMatchPreviewPage> createState() =>
      _DriveTeamMatchPreviewPageState();
}

class _DriveTeamMatchPreviewPageState extends State<DriveTeamMatchPreviewPage> {
  final ValueNotifier<double> _currentPageNotifier = ValueNotifier(0.0);
  PageController? _pageController;

  final List<List<String>> _cards = const [
    ['Bear Metal', '2046'],
    ['Bear Metal', '2046'],
    ['Bear Metal', '2046'],
    ['Jack in the Bot', '2910'],
    ['Jack in the Bot', '2910'],
    ['Jack in the Bot', '2910'],
  ];

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
    final mainViewController = MainViewController.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Qualifier ${widget.matchId}'),
        leading:
            mainViewController.isDesktop
                ? null
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: mainViewController.openDrawer,
                ),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              if ((int.tryParse(widget.matchId) ?? 1) != 1) {
                context.go(
                  '/drive_team/notes/${int.tryParse(widget.matchId)! - 1}',
                );
              }
            },
            icon: Icon(Symbols.arrow_back),
          ),
          SizedBox(width: 12),
          FilledButton(
            onPressed: () => context.go('/drive_team/notes/${widget.matchId}'),
            child: Text('Next'),
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 12),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final cardWidth = (width - 16).clamp(0.0, 600.0);
          final fraction =
              width > 0 ? (cardWidth / width).clamp(0.0, 1.0) : 1.0;

          final stride = width * fraction;
          final contentLeftEdge = (width - cardWidth) / 2.0 + 8.0;

          _updatePageController(fraction, _currentPageNotifier.value.round());

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
                        _buildStickyLabel(
                          context: context,
                          label: "Your Alliance",
                          groupStartIndex: 0,
                          groupEndIndex: 2,
                          page: page,
                          stride: stride,
                          cardWidth: cardWidth,
                          baseOffset: contentLeftEdge,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        _buildStickyLabel(
                          context: context,
                          label: "Blue Alliance",
                          groupStartIndex: 3,
                          groupEndIndex: 5,
                          page: page,
                          stride: stride,
                          cardWidth: cardWidth,
                          baseOffset: contentLeftEdge,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                      _currentPageNotifier.value = _pageController?.page ?? 0.0;
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TeamCard(
                          teamName: _cards[index][0],
                          teamNumber: _cards[index][1],
                        ),
                      );
                    },
                  ),
                ),
              ),

              ValueListenableBuilder<double>(
                valueListenable: _currentPageNotifier,
                builder: (context, page, _) {
                  return DotsIndicator(
                    dotsCount: _cards.length,
                    position: page,
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
                          Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        builder: (BuildContext context) {
                          return Center();
                        },
                      );
                    },
                    child: Text('Scout Lead Notes'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
