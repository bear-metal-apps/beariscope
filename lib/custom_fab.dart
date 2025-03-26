import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomFab {
  final SpeedDialDirection direction;
  final bool switchLabelPosition;
  final double elevation;

  CustomFab({
    this.direction = SpeedDialDirection.up,
    this.switchLabelPosition = false,
    this.elevation = 4.0,
  });

  Widget build(BuildContext context) {
    return SpeedDial(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      direction: direction,
      animationCurve: Curves.easeInOut,
      switchLabelPosition: switchLabelPosition,
      elevation: elevation,
      icon: Symbols.add_rounded,
      iconTheme: const IconThemeData(size: 24),
      activeIcon: Symbols.close_rounded,
      spacing: 4,
      spaceBetweenChildren: 8,
      closeDialOnPop: true,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () {
        HapticFeedback.mediumImpact();
      },
      onClose: () {
        HapticFeedback.mediumImpact();
      },
      children: [
        SpeedDialChild(
          label: 'Match Schedule',
          child: const Icon(Symbols.event_note_rounded),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        SpeedDialChild(
          label: 'Shift Schedule',
          child: const Icon(Symbols.event_rounded),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        SpeedDialChild(
          label: 'Picklist',
          child: const Icon(Symbols.format_list_numbered_rounded),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        SpeedDialChild(
          label: 'From Spreadsheet',
          child: const Icon(Symbols.table_rounded),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        SpeedDialChild(
          label: 'From JSON',
          child: const Icon(Symbols.file_json_rounded),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }
}
