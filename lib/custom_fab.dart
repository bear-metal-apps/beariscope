import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomFab {
  final SpeedDialDirection direction;
  final bool switchLabelPosition;
  final double elevation;

  final bool isOpenOnStart;
  final Function(bool)? onToggle;

  // Controller to track and control the open state
  final ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

  CustomFab({
    this.direction = SpeedDialDirection.up,
    this.switchLabelPosition = false,
    this.elevation = 4.0,
    this.isOpenOnStart = false,
    this.onToggle,
  }) {
    isDialOpen.value = isOpenOnStart;
  }

  Widget build(BuildContext context) {
    return SpeedDial(
      openCloseDial: isDialOpen,
      // Structural properties
      direction: direction,
      switchLabelPosition: switchLabelPosition,
      spacing: 4,
      spaceBetweenChildren: 8,
      closeDialOnPop: true,
      isOpenOnStart: isOpenOnStart,

      // Visual properties
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      elevation: elevation,
      overlayColor: Colors.black,
      overlayOpacity: 0.0,

      // Animation
      animationCurve: Curves.fastOutSlowIn,

      // Icons
      icon: Symbols.add_rounded,
      activeIcon: Symbols.close_rounded,
      iconTheme: const IconThemeData(size: 24),

      onOpen: () {
        if (onToggle != null) {
          onToggle!(true);
        }
      },
      onClose: () {
        if (onToggle != null) {
          onToggle!(false);
        }
      },
      children: [
        SpeedDialChild(
          label: 'Match Schedule',
          child: const Icon(Symbols.event_note_rounded, fill: 1.0),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          labelBackgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
          onTap: () {},
        ),
        SpeedDialChild(
          label: 'Shift Schedule',
          child: const Icon(Symbols.event_rounded, fill: 1.0),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          labelBackgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
          onTap: () {},
        ),
        SpeedDialChild(
          label: 'Picklist',
          child: const Icon(Symbols.format_list_numbered_rounded, fill: 1.0),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          labelBackgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
          onTap: () {},
        ),
        SpeedDialChild(
          label: 'From Spreadsheet',
          child: const Icon(Symbols.table_rounded, fill: 1.0),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          labelBackgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xlsx'],
            );
          },
        ),
        SpeedDialChild(
          label: 'From JSON',
          child: const Icon(Symbols.file_json_rounded, fill: 1.0),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          labelBackgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['json'],
            );
          },
        ),
      ],
    );
  }
}
