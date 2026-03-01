import 'dart:math' as math;

import 'package:beariscope/models/pits_map_data.dart';
import 'package:flutter/material.dart';

class PitsMapView extends StatefulWidget {
  final PitsMapData mapData;

  final Set<int> scoutedTeams;

  final Map<int, String> teamNames;

  final void Function(int teamNumber, String teamName) onTeamTap;

  const PitsMapView({
    super.key,
    required this.mapData,
    required this.scoutedTeams,
    required this.teamNames,
    required this.onTeamTap,
  });

  @override
  State<PitsMapView> createState() => _PitsMapViewState();
}

class _PitsMapViewState extends State<PitsMapView> {
  final TransformationController _controller = TransformationController();

  /// The mapData we last fitted to, used to detect when to re-fit.
  PitsMapData? _lastFittedData;
  BoxConstraints? _lastConstraints;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fitToScreen(BoxConstraints constraints) {
    final mapW = widget.mapData.mapSize.x;
    final mapH = widget.mapData.mapSize.y;
    if (mapW <= 0 || mapH <= 0) return;

    final fitScale =
        math.min(constraints.maxWidth / mapW, constraints.maxHeight / mapH) *
        0.90;

    final tx = (constraints.maxWidth - mapW * fitScale) / 2.0;
    final ty = (constraints.maxHeight - mapH * fitScale) / 2.0;

    _controller.value =
        Matrix4.identity()
          ..translateByDouble(tx, ty, 0, 1)
          ..scaleByDouble(fitScale, fitScale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final needsFit =
            _lastFittedData != widget.mapData ||
            _lastConstraints != constraints;

        if (needsFit) {
          _lastFittedData = widget.mapData;
          _lastConstraints = constraints;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fitToScreen(constraints);
          });
        }

        return ClipRect(
          child: InteractiveViewer(
            transformationController: _controller,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.4,
            maxScale: 10.0,
            constrained: false,
            trackpadScrollCausesScale: true,
            child: _MapCanvas(
              mapData: widget.mapData,
              scoutedTeams: widget.scoutedTeams,
              teamNames: widget.teamNames,
              onTeamTap: widget.onTeamTap,
              theme: theme,
            ),
          ),
        );
      },
    );
  }
}

class _MapCanvas extends StatelessWidget {
  final PitsMapData mapData;
  final Set<int> scoutedTeams;
  final Map<int, String> teamNames;
  final void Function(int teamNumber, String teamName) onTeamTap;
  final ThemeData theme;

  const _MapCanvas({
    required this.mapData,
    required this.scoutedTeams,
    required this.teamNames,
    required this.onTeamTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: mapData.mapSize.x,
      height: mapData.mapSize.y,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // layer 1: decorative shit
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _MapBackgroundPainter(mapData: mapData, theme: theme),
              ),
            ),
          ),
          // layer 2: interactive pit widgets
          ..._buildPitWidgets(),
        ],
      ),
    );
  }

  List<Widget> _buildPitWidgets() {
    return mapData.pits.entries.map((entry) {
      final pit = entry.value;
      final teamNum = pit.teamNumber;

      final box = _PitBox(
        width: pit.size.x,
        height: pit.size.y,
        teamNumber: teamNum,
        scouted: teamNum != null && scoutedTeams.contains(teamNum),
        onTap:
            teamNum != null
                ? () => onTeamTap(teamNum, teamNames[teamNum] ?? '')
                : null,
        theme: theme,
      );

      // the pos is the center of the box, so offset by half to get the top-left
      Widget child = box;
      if (pit.angle != null && pit.angle != 0) {
        child = Transform.rotate(
          angle: pit.angleRadians,
          alignment: Alignment.center,
          child: child,
        );
      }

      return Positioned(
        left: pit.position.x - pit.size.x / 2,
        top: pit.position.y - pit.size.y / 2,
        child: child,
      );
    }).toList();
  }
}

class _MapBackgroundPainter extends CustomPainter {
  final PitsMapData mapData;
  final ThemeData theme;

  const _MapBackgroundPainter({required this.mapData, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintAreas(canvas);
    _paintWalls(canvas);
    _paintArrows(canvas);
    _paintLabels(canvas);
  }

  // floor
  void _paintBackground(Canvas canvas, Size size) {
    //right now it's just the same color as the bg, but here for future uses maybe?
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.colorScheme.surface,
    );
  }

  // areas like shop, restroom, etc
  void _paintAreas(Canvas canvas) {
    final cs = theme.colorScheme;
    final fills = [
      cs.primaryContainer,
      cs.secondaryContainer,
      cs.tertiaryContainer,
      cs.surfaceContainerHigh,
    ];

    int idx = 0;
    for (final entry in mapData.areas.entries) {
      final a = entry.value;
      final fillColor = fills[idx % fills.length];
      idx++;

      final fillPaint =
          Paint()
            ..color = fillColor
            ..style = PaintingStyle.fill;
      final borderPaint =
          Paint()
            ..color = cs.onSurface
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      _withTransform(canvas, a, () {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: a.size.x,
          height: a.size.y,
        );
        canvas.drawRect(rect, fillPaint);

        const sw = 2.0;
        final borderRect = Rect.fromCenter(
          center: Offset.zero,
          width: a.size.x - sw,
          height: a.size.y - sw,
        );
        canvas.drawRect(borderRect, borderPaint);

        _paintCenteredText(
          canvas,
          a.label,
          rect,
          color: cs.onSurface,
          fontSize: (math.min(
            a.size.x * 0.18,
            a.size.y * 0.28,
          )).clamp(8.0, 36.0),
          bold: true,
        );
      });
    }
  }

  // walls
  void _paintWalls(Canvas canvas) {
    final paint =
        Paint()
          ..color = theme.colorScheme.surfaceContainerHigh
          ..style = PaintingStyle.fill;

    for (final entry in mapData.walls.entries) {
      final w = entry.value;
      _withTransform(canvas, w, () {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: w.size.x,
            height: w.size.y,
          ),
          paint,
        );
      });
    }
  }

  // arrows
  void _paintArrows(Canvas canvas) {
    final paint =
        Paint()
          ..color = theme.colorScheme.onSurface
          ..style = PaintingStyle.fill;

    for (final entry in mapData.arrows.entries) {
      final a = entry.value;
      final r = math.min(a.size.x, a.size.y) * 0.38;

      canvas.save();
      canvas.translate(a.position.x, a.position.y);
      if (a.angle != null && a.angle != 0) canvas.rotate(a.angleRadians);

      final path =
          a.type == 'double'
              ? (Path()
                ..moveTo(0, -r) // top tip
                ..lineTo(r * 0.65, -r * 0.35) // top-right of top arrowhead base
                ..lineTo(r * 0.15, -r * 0.35) // shaft top-right
                ..lineTo(r * 0.15, r * 0.35) // shaft bottom-right
                ..lineTo(
                  r * 0.65,
                  r * 0.35,
                ) // bottom-right of bottom arrowhead base
                ..lineTo(0, r) // bottom tip
                ..lineTo(
                  -r * 0.65,
                  r * 0.35,
                ) // bottom-left of bottom arrowhead base
                ..lineTo(-r * 0.15, r * 0.35) // shaft bottom-left
                ..lineTo(-r * 0.15, -r * 0.35) // shaft top-left
                ..lineTo(-r * 0.65, -r * 0.35) // top-left of top arrowhead base
                ..close())
              : (Path()
                ..moveTo(0, -r) // tip
                ..lineTo(r * 0.65, -r * 0.35) // right arrowhead base
                ..lineTo(r * 0.15, -r * 0.35) // shaft top-right
                ..lineTo(r * 0.15, r * 0.6) // shaft bottom-right
                ..lineTo(-r * 0.15, r * 0.6) // shaft bottom-left
                ..lineTo(-r * 0.15, -r * 0.35) // shaft top-left
                ..lineTo(-r * 0.65, -r * 0.35) // left arrowhead base
                ..close());
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  // labels
  void _paintLabels(Canvas canvas) {
    for (final entry in mapData.labels.entries) {
      final l = entry.value;
      _withTransform(canvas, l, () {
        _paintCenteredText(
          canvas,
          l.label,
          Rect.fromCenter(
            center: Offset.zero,
            width: l.size.x,
            height: l.size.y,
          ),
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: math.min(l.size.x * 0.25, l.size.y * 0.70).clamp(8.0, 28.0),
          bold: true,
        );
      });
    }
  }

  void _withTransform(
    Canvas canvas,
    MapComponentBase component,
    void Function() draw,
  ) {
    canvas.save();
    canvas.translate(component.position.x, component.position.y);
    if (component.angle != null && component.angle != 0) {
      canvas.rotate(component.angleRadians);
    }
    draw();
    canvas.restore();
  }

  void _paintCenteredText(
    Canvas canvas,
    String text,
    Rect rect, {
    required Color color,
    required double fontSize,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 4,
    )..layout(maxWidth: math.max(rect.width, 1.0));

    painter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_MapBackgroundPainter old) =>
      old.mapData != mapData || old.theme != theme;
}

// pit widget
class _PitBox extends StatelessWidget {
  final double width;
  final double height;
  final int? teamNumber;
  final bool scouted;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _PitBox({
    required this.width,
    required this.height,
    required this.teamNumber,
    required this.scouted,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final hasTeam = teamNumber != null;

    final Color borderColor;
    final Color bgColor;
    final Color textColor;

    if (!hasTeam || scouted) {
      borderColor = cs.outlineVariant;
      bgColor = cs.surfaceContainerHighest;
      textColor = cs.outline;
    } else {
      borderColor = cs.error;
      bgColor = cs.errorContainer;
      textColor = cs.onErrorContainer;
    }

    // black magic font size
    final rawFontSize = math.min(width * 0.28, height * 0.36);
    final fontSize = rawFontSize.clamp(5.0, 36.0);

    Widget child = Center(
      child:
          hasTeam
              ? Padding(
                padding: EdgeInsets.all(math.max(width, height) * 0.04),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$teamNumber',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      fontFamily: 'Xolonium',
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              )
              : null,
    );

    Widget inner = Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: SizedBox(width: width, height: height, child: child),
      ),
    );

    return SizedBox(width: width, height: height, child: inner);
  }
}
