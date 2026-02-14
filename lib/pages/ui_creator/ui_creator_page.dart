import 'dart:convert';
import 'dart:math';

import 'package:beariscope/utils/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum UiWidgetKind { slider, button, dropdown }

class UiWidgetConfig {
  UiWidgetConfig({
    required this.id,
    required this.kind,
    required this.position,
    required this.sizeInCells,
    this.sliderValue = 0.4,
    this.buttonLabel = 'Action',
    this.dropdownValue = 'Mode A',
  });

  final String id;
  final UiWidgetKind kind;
  Offset position;
  Size sizeInCells;
  double sliderValue;
  String buttonLabel;
  String dropdownValue;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'position': {'x': position.dx, 'y': position.dy},
      'size': {'w': sizeInCells.width, 'h': sizeInCells.height},
      'sliderValue': sliderValue,
      'buttonLabel': buttonLabel,
      'dropdownValue': dropdownValue,
    };
  }
}

class UiCreatorPage extends StatefulWidget {
  const UiCreatorPage({super.key});

  @override
  State<UiCreatorPage> createState() => _UiCreatorPageState();
}

class _UiCreatorPageState extends State<UiCreatorPage> {
  static const double _cellSize = 110;
  static const double _cellGap = 12;
  static const double _canvasPadding = 16;

  final List<UiWidgetConfig> _widgets = [
    UiWidgetConfig(
      id: 'slider_1',
      kind: UiWidgetKind.slider,
      position: const Offset(0, 0),
      sizeInCells: const Size(2, 1),
      sliderValue: 0.6,
    ),
    UiWidgetConfig(
      id: 'button_1',
      kind: UiWidgetKind.button,
      position: const Offset(2, 0),
      sizeInCells: const Size(1, 1),
      buttonLabel: 'Start',
    ),
    UiWidgetConfig(
      id: 'dropdown_1',
      kind: UiWidgetKind.dropdown,
      position: const Offset(0, 1),
      sizeInCells: const Size(2, 1),
      dropdownValue: 'Mode B',
    ),
  ];

  Size _canvasSize = Size.zero;
  UiWidgetConfig? _dragging;
  Offset _dragStart = Offset.zero;
  Offset _widgetStart = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Creator'),
        actions: [
          IconButton(
            onPressed: _resetLayout,
            icon: const Icon(Symbols.restart_alt_rounded),
            tooltip: 'Reset layout',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              _buildBackground(context),
              _buildCanvas(context),
              Positioned(
                top: 16,
                right: 16,
                child: FilledButton.icon(
                  icon: const Icon(Symbols.download_rounded),
                  label: const Text('Export JSON'),
                  onPressed: _exportLayout,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_canvasPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CustomPaint(
            painter: _GridPainter(
              cellSize: _cellSize,
              gap: _cellGap,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            child: Stack(
              children: [
                for (final config in _widgets) _buildWidgetTile(context, config),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetTile(BuildContext context, UiWidgetConfig config) {
    final width = _cellSpan(config.sizeInCells.width);
    final height = _cellSpan(config.sizeInCells.height);
    final position = _cellOffset(config.position);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      left: position.dx,
      top: position.dy,
      width: width,
      height: height,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              _buildTileHeader(context, config),
              Expanded(child: _buildTileBody(context, config)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTileHeader(BuildContext context, UiWidgetConfig config) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _labelForKind(config.kind),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          GestureDetector(
            onPanStart: (details) => _startDrag(config, details),
            onPanUpdate: (details) => _updateDrag(config, details),
            onPanEnd: (_) => _endDrag(config),
            child: Icon(
              Symbols.drag_indicator_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileBody(BuildContext context, UiWidgetConfig config) {
    switch (config.kind) {
      case UiWidgetKind.slider:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Intensity',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: config.sliderValue,
                onChanged: (value) {
                  setState(() {
                    config.sliderValue = value;
                  });
                },
              ),
              Text(
                '${(config.sliderValue * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      case UiWidgetKind.button:
        return Center(
          child: FilledButton(
            onPressed: () {},
            child: Text(config.buttonLabel),
          ),
        );
      case UiWidgetKind.dropdown:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mode', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: config.dropdownValue,
                items:
                    const [
                      'Mode A',
                      'Mode B',
                      'Mode C',
                      'Mode D',
                    ]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    config.dropdownValue = value;
                  });
                },
              ),
            ],
          ),
        );
    }
  }

  String _labelForKind(UiWidgetKind kind) {
    switch (kind) {
      case UiWidgetKind.slider:
        return 'Slider';
      case UiWidgetKind.button:
        return 'Button';
      case UiWidgetKind.dropdown:
        return 'Dropdown';
    }
  }

  void _startDrag(UiWidgetConfig config, DragStartDetails details) {
    setState(() {
      _dragging = config;
      _dragStart = details.globalPosition;
      _widgetStart = config.position;
    });
  }

  void _updateDrag(UiWidgetConfig config, DragUpdateDetails details) {
    if (_dragging != config) return;

    final delta = details.globalPosition - _dragStart;
    final proposed = _widgetStart + Offset(
      delta.dx / _cellSize,
      delta.dy / _cellSize,
    );

    setState(() {
      config.position = _clampToCanvas(config, proposed);
    });
  }

  void _endDrag(UiWidgetConfig config) {
    if (_dragging != config) return;

    setState(() {
      config.position = _snapToGrid(_clampToCanvas(config, config.position));
      _dragging = null;
    });
  }

  Offset _snapToGrid(Offset position) {
    return Offset(position.dx.roundToDouble(), position.dy.roundToDouble());
  }

  Offset _clampToCanvas(UiWidgetConfig config, Offset position) {
    final cellsWide = max(1, _availableCells(_canvasSize.width));
    final cellsHigh = max(1, _availableCells(_canvasSize.height));

    final maxX = max(0.0, cellsWide - config.sizeInCells.width);
    final maxY = max(0.0, cellsHigh - config.sizeInCells.height);

    return Offset(
      position.dx.clamp(0.0, maxX),
      position.dy.clamp(0.0, maxY),
    );
  }

  int _availableCells(double maxExtent) {
    final usable = maxExtent - (_canvasPadding * 2);
    return (usable / (_cellSize + _cellGap)).floor();
  }

  double _cellSpan(double cells) {
    return cells * _cellSize + (cells - 1) * _cellGap;
  }

  Offset _cellOffset(Offset cellPosition) {
    return Offset(
      cellPosition.dx * (_cellSize + _cellGap),
      cellPosition.dy * (_cellSize + _cellGap),
    );
  }

  Future<void> _exportLayout() async {
    final payload = {
      'layout': _widgets.map((widget) => widget.toJson()).toList(),
      'cellSize': _cellSize,
      'cellGap': _cellGap,
    };

    final jsonText = const JsonEncoder.withIndent('  ').convert(payload);

    final saved = await saveTextFile(
      fileName: 'beariscope_ui_layout.json',
      contents: jsonText,
    );

    if (!mounted) return;

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export canceled or not supported.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Layout exported.')),
    );
  }

  void _resetLayout() {
    setState(() {
      _widgets
        ..clear()
        ..addAll([
          UiWidgetConfig(
            id: 'slider_1',
            kind: UiWidgetKind.slider,
            position: const Offset(0, 0),
            sizeInCells: const Size(2, 1),
            sliderValue: 0.6,
          ),
          UiWidgetConfig(
            id: 'button_1',
            kind: UiWidgetKind.button,
            position: const Offset(2, 0),
            sizeInCells: const Size(1, 1),
            buttonLabel: 'Start',
          ),
          UiWidgetConfig(
            id: 'dropdown_1',
            kind: UiWidgetKind.dropdown,
            position: const Offset(0, 1),
            sizeInCells: const Size(2, 1),
            dropdownValue: 'Mode B',
          ),
        ]);
    });
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.cellSize,
    required this.gap,
    required this.color,
  });

  final double cellSize;
  final double gap;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1;

    final step = cellSize + gap;
    for (double dx = 0; dx < size.width; dx += step) {
      for (double dy = 0; dy < size.height; dy += step) {
        final rect = Rect.fromLTWH(dx, dy, cellSize, cellSize);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(16)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.cellSize != cellSize ||
        oldDelegate.gap != gap ||
        oldDelegate.color != color;
  }
}
