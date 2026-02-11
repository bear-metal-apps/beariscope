import 'package:beariscope/components/settings_group.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/libkoala.dart';
import 'package:material_symbols_icons/symbols.dart';

final teamEventsProvider = FutureProvider<List<_EventOption>>((ref) async {
  final client = ref.watch(honeycombClientProvider);
  final year = DateTime.now().year;
  final response = await client.get<List<dynamic>>(
    '/events',
    queryParams: {'team': 'frc2046', 'year': year, 'enrich': false},
  );

  final events =
      response
          .whereType<Map>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .map(_EventOption.fromJson)
          .toList();

  events.sort((a, b) {
    final aDate = a.startDate ?? DateTime(0);
    final bDate = b.startDate ?? DateTime(0);
    return aDate.compareTo(bDate);
  });

  return events;
});

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(teamEventsProvider);
    final selectedKey = ref.watch(currentEventProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => _ErrorState(
              error: error,
              onRetry: () => ref.invalidate(teamEventsProvider),
            ),
        data: (events) {
          _EventOption? currentEvent;
          for (final event in events) {
            if (event.key == selectedKey) {
              currentEvent = event;
              break;
            }
          }
          final currentLabel = currentEvent?.name ?? 'Event key: $selectedKey';

          final menuItems =
              events.map((event) {
                return MenuItemButton(
                  onPressed: () {
                    ref
                        .read(currentEventProvider.notifier)
                        .setEventKey(event.key);
                    _menuController.close();
                    setState(() {});
                  },
                  child: Text(event.name),
                );
              }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SettingsGroup(
                title: 'General',
                children: [
                  ListTile(
                    leading: const Icon(Symbols.person_rounded),
                    title: const Text('Account'),
                    subtitle: const Text('Email, Password'),
                    onTap: () => context.push('/settings/account'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.notifications_rounded),
                    title: const Text('Notifications'),
                    subtitle: const Text('Queuing, Schedule Release'),
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.palette_rounded),
                    title: const Text('Appearance'),
                    subtitle: const Text('Theme, UI Options'),
                    onTap: () => context.push('/settings/appearance'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SettingsGroup(
                title: 'Current Event',
                children: [
                  MenuAnchor(
                    controller: _menuController,
                    menuChildren:
                        menuItems.isEmpty
                            ? const [
                              MenuItemButton(
                                onPressed: null,
                                child: Text('No events available'),
                              ),
                            ]
                            : menuItems,
                    builder: (context, controller, child) {
                      return ListTile(
                        leading: const Icon(Symbols.event_rounded),
                        title: const Text('Event'),
                        subtitle: Text(currentLabel),
                        trailing: Icon(
                          controller.isOpen
                              ? Symbols.expand_less_rounded
                              : Symbols.expand_more_rounded,
                        ),
                        onTap:
                            menuItems.isEmpty
                                ? null
                                : () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                  setState(() {});
                                },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SettingsGroup(
                title: 'Team',
                children: [
                  ListTile(
                    leading: const Icon(Symbols.person_add),
                    title: const Text('Scouts'),
                    subtitle: const Text('Add, Remove Scouts'),
                    onTap: () => context.push('/settings/user_selection'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.group),
                    title: const Text('Beariscope Users'),
                    subtitle: const Text('Edit Roles'),
                    onTap: () => context.push('/settings/roles'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About Section
              SettingsGroup(
                title: 'About',
                children: [
                  ListTile(
                    leading: const Icon(Symbols.info_rounded),
                    title: const Text('About'),
                    subtitle: const Text('Version, Acknowledgements'),
                    onTap: () => context.push('/settings/about'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.license_rounded),
                    title: const Text('Licenses'),
                    subtitle: const Text('Licenses, Open Source'),
                    onTap: () => context.push('/settings/licenses'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error fetching events: $error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EventOption {
  final String key;
  final String name;
  final DateTime? startDate;

  const _EventOption({required this.key, required this.name, this.startDate});

  factory _EventOption.fromJson(Map<String, dynamic> json) {
    return _EventOption(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Event',
      startDate: () {
        final raw = json['startDate'] ?? json['start_date'];
        if (raw == null) return null;
        return DateTime.tryParse(raw.toString());
      }(),
    );
  }
}
