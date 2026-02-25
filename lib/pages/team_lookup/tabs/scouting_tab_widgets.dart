// Shared design tokens and widgets used across all scouting-data tabs
// (Averages, Breakdown, Capabilities, Notes).
//
// All tabs use:
//   - 16 px outer list padding
//   - kScoutingSectionGap vertical gap between sections
//   - kScoutingHeaderGap vertical gap between a section header and its card
//   - ScoutingSectionHeader for top-level section labels
//   - ScoutingSubHeader for in-card sub-sections (e.g. phase headers)
//   - ScoutingDataRow for compact key-value rows (all data cards)
//   - ScoutingDataDivider for internal card dividers
//   - scoutingIncidentChip for inline incident badges
//   - scoutingIncidentCountChip for summary-row incident counters

import 'package:flutter/material.dart';

// ─── Spacing constants ────────────────────────────────────────────────────────

/// Vertical gap between top-level sections on a scouting tab.
const double kScoutingSectionGap = 16;

/// Vertical gap between a [ScoutingSectionHeader] and the card that follows it.
const double kScoutingHeaderGap = 8;

// ─── Section headers ──────────────────────────────────────────────────────────

/// Top-level section header used *outside* cards.
///
/// Renders a coloured icon (18 px) followed by a bold [titleSmall] label,
/// both in the theme's primary colour.
class ScoutingSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const ScoutingSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// In-card sub-header used to label sections *inside* an expanded card
/// (e.g. Auto / Teleop / Endgame phase headers in the Breakdown tab).
///
/// Slightly smaller than [ScoutingSectionHeader] — uses [labelMedium].
class ScoutingSubHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const ScoutingSubHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data row (compact key-value) ─────────────────────────────────────────────

/// A compact 50/50 key-value row for data-dense cards (capabilities,
/// breakdown detail, etc.).
///
/// Both [label] and [value] use [bodySmall]. The label is tinted
/// [onSurfaceVariant]; the value is right-aligned. When [highlight] is true
/// the value is shown in the primary colour with bold weight.
class ScoutingDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const ScoutingDataRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  highlight
                      ? Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )
                      : Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dividers ─────────────────────────────────────────────────────────────────

/// Divider for use inside data-row cards (all tabs).
class ScoutingDataDivider extends StatelessWidget {
  const ScoutingDataDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1),
    );
  }
}

// ─── Date formatting utility ──────────────────────────────────────────────────

/// Formats a [DateTime] as "M/D" for compact match labels.
///
/// Used in both [BreakdownTab] and [NotesTab] when a match number is unknown.
String scoutingShortDate(DateTime dt) => '${dt.month}/${dt.day}';

// ─── Chips ────────────────────────────────────────────────────────────────────

/// A compact coloured incident chip with white label text.
///
/// Used inline in match card headers and in per-match note rows.
Widget scoutingIncidentChip(BuildContext context, String label) {
  return Chip(
    label: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onError,
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.error,
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

/// An incident counter chip for the Notes tab summary row.
///
/// The chip is highlighted in [color] only when [count] > 0.
Widget scoutingIncidentCountChip(
  BuildContext context,
  String label,
  int count,
) {
  final active = count > 0;
  return Chip(
    label: Text(
      '$label: $count',
      style: TextStyle(
        fontSize: 12,
        color:
            active
                ? Theme.of(context).colorScheme.onError
                : Theme.of(context).colorScheme.onSurface,
      ),
    ),
    backgroundColor:
        active
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.surfaceContainerHigh,
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
  );
}
