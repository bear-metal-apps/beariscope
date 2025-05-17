import 'package:beariscope/popups/import_from_json.dart';
import 'package:beariscope/popups/import_from_spreadsheet.dart';
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
        _buildSpeedDialChild(
          context,
          'Match Schedule',
          Symbols.scoreboard_rounded,
          () {},
        ),
        _buildSpeedDialChild(
          context,
          'Shift Schedule',
          Symbols.event_rounded,
          () {},
        ),
        _buildSpeedDialChild(
          context,
          'Picklist',
          Symbols.format_list_numbered_rounded,
          () {},
        ),
        _buildSpeedDialChild(
          context,
          'From Spreadsheet',
          Symbols.table_rounded,
          () {
            showDialog(
              context: context,
              builder: (context) => const ImportFromSpreadsheetPopup(),
            );
          },
        ),
        _buildSpeedDialChild(
          context,
          'From JSON',
          Symbols.file_json_rounded,
          () {
            showDialog(
              context: context,
              builder: (context) => const ImportFromJsonPopup(),
            );
          },
        ),
      ],
    );
  }

  SpeedDialChild _buildSpeedDialChild(
    BuildContext context,
    String label,
    IconData icon,
    Function onTap,
  ) {
    return SpeedDialChild(
      label: label,
      child: Icon(icon, fill: 1.0),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      labelBackgroundColor: Theme.of(context).colorScheme.tertiary,
      foregroundColor: Theme.of(context).colorScheme.onTertiary,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
      onTap: () {
        onTap();
      },
    );
  }
}
