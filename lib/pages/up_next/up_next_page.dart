import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/up_next/up_next_provider.dart';
import 'package:beariscope/pages/up_next/up_next_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class UpNextPage extends ConsumerWidget {
  const UpNextPage({super.key});

  static final DateFormat timeFormat = DateFormat("EEEE, MMM d 'at' h:mm a");
  static final DateFormat eventDateFormat = DateFormat('EEEE, MMM d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = MainViewController.of(context);
    final scheduleAsync = ref.watch(upcomingScheduleProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Up Next'),
          leading:
              controller.isDesktop
                  ? null
                  : IconButton(
                    icon: const Icon(Symbols.menu_rounded),
                    onPressed: controller.openDrawer,
                  ),
          bottom: const TabBar(tabs: [Tab(text: 'Current'), Tab(text: 'Past')]),
        ),
        body: scheduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (err, stack) =>
                  Center(child: Text('Error fetching schedule: $err')),
          data: (schedule) {
            final now = DateTime.now();
            final currentEvents = <Map<String, dynamic>>[];
            final pastEvents = <Map<String, dynamic>>[];

            for (final item in schedule) {
              final event = item['event'] as Map<String, dynamic>;
              final endDate = _parseDate(event['endDate'] ?? event['end_date']);
              if (endDate == null) {
                pastEvents.add(item);
              } else if (endDate.add(const Duration(days: 1)).isBefore(now)) {
                pastEvents.add(item);
              } else {
                currentEvents.add(item);
              }
            }

            return TabBarView(
              children: [
                _EventList(
                  items: currentEvents,
                  emptyMessage: 'No Current Events found.',
                  timeFormat: timeFormat,
                ),
                _EventList(
                  items: pastEvents,
                  emptyMessage: 'No Past Events found.',
                  timeFormat: timeFormat,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateFormat timeFormat;

  const _EventSection({required this.data, required this.timeFormat});

  @override
  Widget build(BuildContext context) {
    final event = data['event'] as Map<String, dynamic>;
    final matches =
        (data['matches'] as List?)
            ?.whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList() ??
        const <Map<String, dynamic>>[];
    final eventName = event['name']?.toString() ?? 'Unknown Event';

    if (matches.isEmpty) {
      return UpNextEventCard(
        eventKey: event['key']?.toString() ?? '',
        name: eventName,
        dateLabel: _formatEventDate(event),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(eventName, style: TextStyle(fontFamily: 'Xolonium')),
          ...matches.map((match) {
            final matchTime = _parseMatchTime(match);
            final timeLabel =
                matchTime == null ? 'Time TBD' : timeFormat.format(matchTime);

            String displayName;
            final compLevel = _stringValue(match, 'compLevel', 'comp_level');
            final matchNumber = _intValue(match, 'matchNumber', 'match_number');
            switch (compLevel) {
              case 'qm':
                displayName = 'Qualification Match ${matchNumber ?? ''}'.trim();
              case 'sf':
                displayName = 'Semifinal Match ${matchNumber ?? ''}'.trim();
              case 'f':
                displayName = 'Final Match ${matchNumber ?? ''}'.trim();
              default:
                displayName = _defaultMatchName(match, compLevel, matchNumber);
            }

            return UpNextMatchCard(
              matchKey: match['key']?.toString() ?? '',
              displayName: displayName,
              time: timeLabel,
            );
          }),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String emptyMessage;
  final DateFormat timeFormat;

  const _EventList({
    required this.items,
    required this.emptyMessage,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return BeariscopeCardList(
      children:
          items.map((item) {
            return _EventSection(data: item, timeFormat: timeFormat);
          }).toList(),
    );
  }
}

String _formatEventDate(Map<String, dynamic> event) {
  final startDate = _parseDate(event['startDate'] ?? event['start_date']);
  if (startDate == null) {
    return 'Date TBA';
  }
  return UpNextPage.eventDateFormat.format(startDate);
}

DateTime? _parseMatchTime(Map<String, dynamic> match) {
  final value = match['predictedTime'] ?? match['predicted_time'];
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

String _stringValue(Map<String, dynamic> map, String primary, String fallback) {
  return map[primary]?.toString() ?? map[fallback]?.toString() ?? '';
}

int? _intValue(Map<String, dynamic> map, String primary, String fallback) {
  final value = map[primary] ?? map[fallback];
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

String _defaultMatchName(
  Map<String, dynamic> match,
  String compLevel,
  int? matchNumber,
) {
  if (compLevel.isEmpty) {
    return match['key']?.toString() ?? '';
  }
  if (matchNumber != null) {
    return '$compLevel $matchNumber';
  }
  return compLevel;
}
