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

  UiWidgetConfig clone() {
    return UiWidgetConfig(
      id: id,
      kind: kind,
      position: position,
      sizeInCells: sizeInCells,
      sliderValue: sliderValue,
      buttonLabel: buttonLabel,
      dropdownValue: dropdownValue,
    );
  }

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

class _LayoutPreset {
  const _LayoutPreset({
    required this.name,
    required this.widgets,
    required this.cellSize,
    required this.cellGap,
  });

  final String name;
  final List<UiWidgetConfig> widgets;
  final double cellSize;
  final double cellGap;
}

enum _CreatorMenuAction {
  savePreset,
  addSlider,
  addButton,
  addDropdown,
  resetLayout,
}

class UiCreatorPage extends StatefulWidget {
  const UiCreatorPage({super.key});

  @override
  State<UiCreatorPage> createState() => _UiCreatorPageState();
}

class _UiCreatorPageState extends State<UiCreatorPage> {
  static const double _minCellSize = 80;
  static const double _maxCellSize = 160;
  static const double _minCellGap = 4;
  static const double _maxCellGap = 24;
  static const double _canvasPadding = 16;

  double _cellSize = 110;
  double _cellGap = 12;

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
  int _widgetSerial = 2;

  final List<_LayoutPreset> _presets = [];
  String _selectedPresetName = 'Current';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Creator'),
        actions: [
          _buildPresetSelector(),
          IconButton(
            onPressed: _exportLayout,
            icon: const Icon(Symbols.download_rounded),
            tooltip: 'Export JSON',
          ),
          PopupMenuButton<_CreatorMenuAction>(
            tooltip: 'Actions',
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _CreatorMenuAction.savePreset,
                child: Text('Save preset'),
              ),
              const PopupMenuItem(
                value: _CreatorMenuAction.addButton,
                child: Text('Add button'),
              ),
              const PopupMenuItem(
                value: _CreatorMenuAction.addSlider,
                child: Text('Add slider'),
              ),
              const PopupMenuItem(
                value: _CreatorMenuAction.addDropdown,
                child: Text('Add dropdown'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _CreatorMenuAction.resetLayout,
                child: Text('Reset layout'),
              ),
            ],
            icon: const Icon(Symbols.more_vert_rounded),
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
                left: 24,
                bottom: 24,
                child: _buildGridControls(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPresetSelector() {
    final items = [
      const DropdownMenuItem(value: 'Current', child: Text('Current')),
      ..._presets.map(
        (preset) => DropdownMenuItem(
          value: preset.name,
          child: Text(preset.name),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPresetName,
          items: items,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedPresetName = value;
            });
            if (value == 'Current') return;
            final preset = _presets.firstWhere(
              (entry) => entry.name == value,
            );
            _applyPreset(preset);
          },
        ),
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
                initialValue: config.dropdownValue,
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
      delta.dx / (_cellSize + _cellGap),
      delta.dy / (_cellSize + _cellGap),
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
      _cellSize = 110;
      _cellGap = 12;
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
      _selectedPresetName = 'Current';
    });
  }

  Widget _buildGridControls(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grid size',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('Cell size: ${_cellSize.round()}'),
            Slider(
              min: _minCellSize,
              max: _maxCellSize,
              value: _cellSize,
              onChanged: (value) {
                setState(() {
                  _cellSize = value;
                  _normalizeLayout();
                });
              },
            ),
            Text('Cell gap: ${_cellGap.round()}'),
            Slider(
              min: _minCellGap,
              max: _maxCellGap,
              value: _cellGap,
              onChanged: (value) {
                setState(() {
                  _cellGap = value;
                  _normalizeLayout();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(_CreatorMenuAction action) {
    switch (action) {
      case _CreatorMenuAction.savePreset:
        _showSavePresetDialog();
        break;
      case _CreatorMenuAction.addButton:
        _addWidget(UiWidgetKind.button);
        break;
      case _CreatorMenuAction.addSlider:
        _addWidget(UiWidgetKind.slider);
        break;
      case _CreatorMenuAction.addDropdown:
        _addWidget(UiWidgetKind.dropdown);
        break;
      case _CreatorMenuAction.resetLayout:
        _resetLayout();
        break;
    }
  }

  Future<void> _showSavePresetDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save preset'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Preset name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name == null || name.trim().isEmpty) return;

    final uniqueName = _uniquePresetName(name.trim());
    final preset = _LayoutPreset(
      name: uniqueName,
      widgets: _widgets.map((widget) => widget.clone()).toList(),
      cellSize: _cellSize,
      cellGap: _cellGap,
    );

    setState(() {
      _presets.add(preset);
      _selectedPresetName = uniqueName;
    });
  }

  String _uniquePresetName(String base) {
    if (_presets.every((preset) => preset.name != base)) {
      return base;
    }

    var counter = 2;
    while (_presets.any((preset) => preset.name == '$base $counter')) {
      counter++;
    }
    return '$base $counter';
  }

  void _applyPreset(_LayoutPreset preset) {
    setState(() {
      _cellSize = preset.cellSize;
      _cellGap = preset.cellGap;
      _widgets
        ..clear()
        ..addAll(preset.widgets.map((widget) => widget.clone()));
      _normalizeLayout();
    });
  }

  void _normalizeLayout() {
    for (final widget in _widgets) {
      widget.position = _snapToGrid(_clampToCanvas(widget, widget.position));
    }
  }

  void _addWidget(UiWidgetKind kind) {
    final size = switch (kind) {
      UiWidgetKind.slider => const Size(2, 1),
      UiWidgetKind.button => const Size(1, 1),
      UiWidgetKind.dropdown => const Size(2, 1),
    };

    final position = _findNextOpenCell(size);
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No space left on the grid.')),
      );
      return;
    }

    setState(() {
      _widgets.add(
        UiWidgetConfig(
          id: 'widget_${_widgetSerial++}',
          kind: kind,
          position: position,
          sizeInCells: size,
        ),
      );
      _selectedPresetName = 'Current';
    });
  }

  Offset? _findNextOpenCell(Size sizeInCells) {
    final cellsWide = max(1, _availableCells(_canvasSize.width));
    final cellsHigh = max(1, _availableCells(_canvasSize.height));

    final maxX = max(0, cellsWide - sizeInCells.width.toInt());
    final maxY = max(0, cellsHigh - sizeInCells.height.toInt());

    for (int y = 0; y <= maxY; y++) {
      for (int x = 0; x <= maxX; x++) {
        final candidate = Offset(x.toDouble(), y.toDouble());
        if (!_overlapsAny(candidate, sizeInCells)) {
          return candidate;
        }
      }
    }

    return null;
  }

  bool _overlapsAny(Offset position, Size sizeInCells) {
    final candidate = Rect.fromLTWH(
      position.dx,
      position.dy,
      sizeInCells.width,
      sizeInCells.height,
    );
    for (final existing in _widgets) {
      final other = Rect.fromLTWH(
        existing.position.dx,
        existing.position.dy,
        existing.sizeInCells.width,
        existing.sizeInCells.height,
      );
      if (candidate.overlaps(other)) {
        return true;
      }
    }
    return false;
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
