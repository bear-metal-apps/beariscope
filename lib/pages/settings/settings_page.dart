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
    cachePolicy: CachePolicy.cacheFirst,
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

  Future<void> _refreshEvents() async {
    final year = DateTime.now().year;
    final client = ref.read(honeycombClientProvider);
    client.invalidateCache(
      '/events',
      queryParams: {'team': 'frc2046', 'year': year, 'enrich': false},
    );
    ref.invalidate(teamEventsProvider);
    try {
      await ref.read(teamEventsProvider.future);
    } catch (_) {
      // Keep current cached data visible if refresh fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = ref.watch(currentEventProvider);
    final permissionChecker = ref.watch(permissionCheckerProvider);
    final canViewScouts =
        permissionChecker?.hasAnyPermission([PermissionKey.scoutsRead]) ??
        false;
    final canEditScouts =
        permissionChecker?.hasPermission(PermissionKey.scoutsManage) ?? false;
    final canManageUsersRoles =
        permissionChecker?.hasPermission(PermissionKey.usersRolesManage) ??
        false;
    final canProvision =
        permissionChecker?.hasPermission(PermissionKey.deviceProvision) ??
        false;
    // only show the event selector when the user has at least one permission
    final canSelectEvent =
        permissionChecker != null && permissionChecker.permissions.isNotEmpty;

    // we only watch the events provider when the user can actually select one.
    final eventsAsync = canSelectEvent ? ref.watch(teamEventsProvider) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RefreshIndicator(
        onRefresh: canSelectEvent ? _refreshEvents : () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                // ListTile(
                //   leading: const Icon(Symbols.notifications_rounded),
                //   title: const Text('Notifications'),
                //   subtitle: const Text('Queuing, Schedule Release'),
                //   onTap: () => context.push('/settings/notifications'),
                // ),
                ListTile(
                  leading: const Icon(Symbols.palette_rounded),
                  title: const Text('Appearance'),
                  subtitle: const Text('Theme, UI Options'),
                  onTap: () => context.push('/settings/appearance'),
                ),
              ],
            ),

            if (canSelectEvent) ...[
              const SizedBox(height: 16),
              eventsAsync!.when(
                loading:
                    () => SettingsGroup(
                      title: 'Current Event',
                      children: [
                        const ListTile(
                          leading: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          title: Text('Loading events…'),
                        ),
                      ],
                    ),
                error:
                    (error, _) => SettingsGroup(
                      title: 'Current Event',
                      children: [
                        ListTile(
                          leading: const Icon(Symbols.error_rounded),
                          title: const Text('Could not load events'),
                          subtitle: const Text('Tap to retry'),
                          onTap: () => ref.invalidate(teamEventsProvider),
                        ),
                      ],
                    ),
                data: (events) {
                  _EventOption? currentEvent;
                  for (final event in events) {
                    if (event.key == selectedKey) {
                      currentEvent = event;
                      break;
                    }
                  }
                  final currentLabel =
                      currentEvent?.name ?? 'Event key: $selectedKey';

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

                  return SettingsGroup(
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
                  );
                },
              ),
            ],

            const SizedBox(height: 16),

            if (canViewScouts ||
                canEditScouts ||
                canManageUsersRoles ||
                canProvision)
              SettingsGroup(
                title: 'Team',
                children: [
                  if (canViewScouts || canEditScouts)
                    ListTile(
                      leading: const Icon(Symbols.group_rounded),
                      title: const Text('Scouts'),
                      subtitle: Text(
                        canEditScouts ? 'Add, Remove Scouts' : 'View Scouts',
                      ),
                      onTap: () => context.push('/settings/user_selection'),
                    ),
                  if (canManageUsersRoles)
                    ListTile(
                      leading: const Icon(Symbols.groups_rounded),
                      title: const Text('Beariscope Users, Roles'),
                      subtitle: const Text('Edit Roles, Permissions, Users'),
                      onTap: () => context.push('/settings/roles'),
                    ),
                  if (canProvision)
                    ListTile(
                      leading: const Icon(Symbols.qr_code_rounded),
                      title: const Text('Device Provisioning'),
                      subtitle: const Text('Generate Pawfinder QR Code'),
                      onTap:
                          () => context.push('/settings/device_provisioning'),
                    ),
                ],
              ),

            if (canViewScouts ||
                canEditScouts ||
                canManageUsersRoles ||
                canProvision)
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
