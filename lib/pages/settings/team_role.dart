import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/libkoala.dart';
import 'package:material_symbols_icons/symbols.dart';

class TeamRolesPage extends ConsumerStatefulWidget {
  const TeamRolesPage({super.key});

  @override
  ConsumerState<TeamRolesPage> createState() => _TeamRolesPageState();
}

class _TeamRolesPageState extends ConsumerState<TeamRolesPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedTab,
    )..addListener(_handleTabChanged);
    _searchController.addListener(_handleSearchChanged);
  }

  void _handleTabChanged() {
    final nextIndex = _tabController.index;
    if (nextIndex == _selectedTab || !mounted) {
      return;
    }

    setState(() => _selectedTab = nextIndex);
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text.trim().toLowerCase();
    if (nextQuery == _searchQuery) {
      return;
    }

    if (!mounted) {
      _searchQuery = nextQuery;
      return;
    }

    setState(() => _searchQuery = nextQuery);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool _isMobileDialog(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  InputDecoration _outlinedInput({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  bool _sameStringSet(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }

  bool _sameStringListAsSet(List<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }

  Future<void> _showRoleDialog({
    ManagedRole? role,
    required List<RbacPermissionMetadata> permissions,
    bool duplicate = false,
  }) async {
    final isEdit = role != null && !duplicate;

    final initialId = duplicate ? '${role?.id ?? ''}_copy' : (role?.id ?? '');
    final initialName =
        duplicate ? '${role?.name ?? ''} Copy' : (role?.name ?? '');
    final initialDescription = role?.description ?? '';
    final initialPermissions = <String>{...?role?.permissions};

    final idController = TextEditingController(text: initialId);
    final nameController = TextEditingController(text: initialName);
    final descriptionController = TextEditingController(
      text: initialDescription,
    );
    final selectedPermissions = <String>{...initialPermissions};

    Future<void> showDialogBody() async {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final currentId = idController.text.trim();
              final currentName = nameController.text.trim();
              final currentDescription = descriptionController.text.trim();

              final hasChanges =
                  currentId != initialId ||
                  currentName != initialName ||
                  currentDescription != initialDescription ||
                  !_sameStringSet(selectedPermissions, initialPermissions);

              final canSave =
                  hasChanges &&
                  currentId.isNotEmpty &&
                  currentName.isNotEmpty &&
                  selectedPermissions.isNotEmpty;

              final titleText =
                  isEdit
                      ? 'Edit Role'
                      : duplicate
                      ? 'Duplicate Role'
                      : 'Create Role';

              Future<void> handleSave() async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final permissionList = selectedPermissions.toList()..sort();

                try {
                  final service = ref.read(rbacManagementServiceProvider);
                  if (isEdit) {
                    await service.updateRole(
                      id: currentId,
                      name: currentName,
                      description:
                          currentDescription.isEmpty ? '' : currentDescription,
                      permissions: permissionList,
                    );
                  } else {
                    await service.createRole(
                      id: currentId,
                      name: currentName,
                      description:
                          currentDescription.isEmpty
                              ? null
                              : currentDescription,
                      permissions: permissionList,
                    );
                  }

                  if (!mounted) return;
                  ref.invalidate(rbacRolesProvider);
                  navigator.pop();
                } catch (error) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to save role: $error')),
                  );
                }
              }

              final formBody = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: idController,
                    enabled: !isEdit,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: _outlinedInput(label: 'Role ID'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: _outlinedInput(label: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: _outlinedInput(label: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Permissions',
                    style: Theme.of(dialogContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...permissions.map(
                    (permission) => CheckboxListTile(
                      value: selectedPermissions.contains(permission.key),
                      title: Text(permission.name),
                      subtitle: Text(permission.description),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedPermissions.add(permission.key);
                          } else {
                            selectedPermissions.remove(permission.key);
                          }
                        });
                      },
                    ),
                  ),
                ],
              );

              if (_isMobileDialog(dialogContext)) {
                return Dialog.fullscreen(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(titleText),
                      actionsPadding: const EdgeInsets.only(right: 12),
                      leading: IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Symbols.close),
                      ),
                      actions: [
                        TextButton(
                          onPressed: canSave ? handleSave : null,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: formBody,
                      ),
                    ),
                  ),
                );
              }

              return AlertDialog(
                title: Text(titleText),
                content: SizedBox(
                  width: 560,
                  child: SingleChildScrollView(child: formBody),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: canSave ? handleSave : null,
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    await showDialogBody();
  }

  Future<void> _deleteRole(ManagedRole role, int assignedUsers) async {
    if (assignedUsers > 0) {
      await showDialog<void>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Cannot delete role'),
              content: Text(
                'This role is assigned to $assignedUsers users. Please reassign them before deleting.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Role'),
            content: Text('Delete ${role.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(rbacManagementServiceProvider).deleteRole(role.id);
      ref.invalidate(rbacRolesProvider);
      ref.invalidate(rbacUsersProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete role: $error')));
    }
  }

  Future<void> _showUserDialog({
    required ManagedUser user,
    required List<ManagedRole> roles,
  }) async {
    final initialName = user.name ?? '';
    final initialRoles = <String>{...user.roles};

    final nameController = TextEditingController(text: initialName);
    final selectedRoles = <String>{...initialRoles};

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final currentName = nameController.text.trim();

            final hasChanges =
                currentName != initialName ||
                !_sameStringListAsSet(user.roles, selectedRoles);

            final canSave = hasChanges;

            Future<void> handleSave() async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                await ref
                    .read(rbacManagementServiceProvider)
                    .updateUserRoles(
                      userId: user.id,
                      name: currentName.isEmpty ? null : currentName,
                      roles: selectedRoles.toList()..sort(),
                    );
                if (!mounted) return;
                ref.invalidate(rbacUsersProvider);
                navigator.pop();
              } catch (error) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to update user: $error')),
                );
              }
            }

            final formBody = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: _outlinedInput(label: 'Name'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Roles',
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (roles.isEmpty)
                  const Text('No roles available.')
                else
                  ...roles.map(
                    (role) => CheckboxListTile(
                      value: selectedRoles.contains(role.id),
                      title: Text(role.name),
                      subtitle:
                          (role.description ?? '').isNotEmpty
                              ? Text(role.description!)
                              : null,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedRoles.add(role.id);
                          } else {
                            selectedRoles.remove(role.id);
                          }
                        });
                      },
                    ),
                  ),
              ],
            );

            if (_isMobileDialog(dialogContext)) {
              return Dialog.fullscreen(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Edit User'),
                    actionsPadding: const EdgeInsets.only(right: 12),
                    leading: IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Symbols.close),
                    ),
                    actions: [
                      TextButton(
                        onPressed: canSave ? handleSave : null,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: formBody,
                    ),
                  ),
                ),
              );
            }

            return AlertDialog(
              title: const Text('Edit User'),
              content: SizedBox(
                width: 620,
                child: SingleChildScrollView(child: formBody),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: canSave ? handleSave : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _emptyState({required String text}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metadataAsync = ref.watch(rbacMetadataProvider);
    final rolesAsync = ref.watch(rbacRolesProvider);
    final usersAsync = ref.watch(rbacUsersProvider);
    final searchQuery = _searchQuery;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        centerTitle: true,
        title: SearchBar(
          controller: _searchController,
          elevation: WidgetStateProperty.all(0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          leading: const Icon(Symbols.search_rounded),
          hintText: _selectedTab == 0 ? 'Search users' : 'Search roles',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Users'), Tab(text: 'Roles')],
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: metadataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) =>
                Center(child: Text('Failed to load metadata: $error')),
        data: (metadata) {
          final permissionMap = {
            for (final permission in metadata.permissions)
              permission.key: permission,
          };

          return TabBarView(
            controller: _tabController,
            children: [
              usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, _) =>
                        Center(child: Text('Failed to load users: $error')),
                data: (users) {
                  final roleMap = {
                    for (final role
                        in rolesAsync.asData?.value ?? const <ManagedRole>[])
                      role.id: role,
                  };

                  final filteredUsers =
                      users.where((user) {
                        if (searchQuery.isEmpty) return true;
                        final roleNames = user.roles
                            .map((roleId) => roleMap[roleId]?.name ?? '')
                            .join(' ');
                        final userText =
                            '${user.name ?? ''} $roleNames'.toLowerCase();
                        return userText.contains(searchQuery);
                      }).toList();

                  if (filteredUsers.isEmpty) {
                    return _emptyState(text: 'No users found');
                  }

                  return BeariscopeCardList(
                    children:
                        filteredUsers
                            .map(
                              (user) => Card(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage:
                                                (user.avatarUrl ?? '')
                                                        .isNotEmpty
                                                    ? NetworkImage(
                                                      user.avatarUrl!,
                                                    )
                                                    : null,
                                            child:
                                                (user.avatarUrl ?? '').isEmpty
                                                    ? const Icon(
                                                      Symbols.person_rounded,
                                                    )
                                                    : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              user.name?.isNotEmpty == true
                                                  ? user.name!
                                                  : 'Unknown User',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed:
                                                () => _showUserDialog(
                                                  user: user,
                                                  roles:
                                                      rolesAsync
                                                          .asData
                                                          ?.value ??
                                                      const [],
                                                ),
                                            icon: Icon(Symbols.edit_rounded),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (user.roles.isEmpty)
                                        const Text('No roles assigned')
                                      else
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children:
                                              user.roles.map((roleId) {
                                                final roleName =
                                                    roleMap[roleId]?.name ??
                                                    'Unknown Role';
                                                return Chip(
                                                  label: Text(roleName),
                                                );
                                              }).toList(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
              rolesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, _) =>
                        Center(child: Text('Failed to load roles: $error')),
                data: (roles) {
                  final users =
                      usersAsync.asData?.value ?? const <ManagedUser>[];
                  final roleUserCounts = <String, int>{};
                  for (final user in users) {
                    for (final roleId in user.roles) {
                      roleUserCounts.update(
                        roleId,
                        (value) => value + 1,
                        ifAbsent: () => 1,
                      );
                    }
                  }

                  final filteredRoles =
                      roles.where((role) {
                        if (searchQuery.isEmpty) return true;
                        final roleText =
                            '${role.name} ${role.description ?? ''} ${role.permissions.join(' ')}'
                                .toLowerCase();
                        return roleText.contains(searchQuery);
                      }).toList();

                  if (filteredRoles.isEmpty) {
                    return _emptyState(text: 'No roles defined');
                  }

                  return BeariscopeCardList(
                    children:
                        filteredRoles
                            .map(
                              (role) => Card(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              role.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (action) {
                                              final assignedUsers =
                                                  roleUserCounts[role.id] ?? 0;
                                              if (action == 'edit') {
                                                _showRoleDialog(
                                                  role: role,
                                                  permissions:
                                                      metadata.permissions,
                                                );
                                              } else if (action ==
                                                  'duplicate') {
                                                _showRoleDialog(
                                                  role: role,
                                                  permissions:
                                                      metadata.permissions,
                                                  duplicate: true,
                                                );
                                              } else if (action == 'delete') {
                                                _deleteRole(
                                                  role,
                                                  assignedUsers,
                                                );
                                              }
                                            },
                                            itemBuilder: (context) {
                                              final assignedUsers =
                                                  roleUserCounts[role.id] ?? 0;
                                              return [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Symbols.edit_rounded,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Edit'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'duplicate',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Symbols
                                                            .content_copy_rounded,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Duplicate'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  enabled: assignedUsers == 0,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Symbols.delete_rounded,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        assignedUsers == 0
                                                            ? 'Delete'
                                                            : 'Delete (assigned to $assignedUsers users)',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ];
                                            },
                                          ),
                                        ],
                                      ),
                                      if ((role.description ?? '').isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(role.description!),
                                        ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            role.permissions.map((
                                              permissionKey,
                                            ) {
                                              final metadataEntry =
                                                  permissionMap[permissionKey];
                                              return Tooltip(
                                                message:
                                                    metadataEntry
                                                        ?.description ??
                                                    '',
                                                child: Chip(
                                                  label: Text(
                                                    metadataEntry?.name ??
                                                        'Unknown Permission',
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: metadataAsync.when(
        loading: () => null,
        error: (_, _) => null,
        data: (metadata) {
          if (_selectedTab != 1) {
            return null;
          }

          return FloatingActionButton.extended(
            onPressed: () {
              _showRoleDialog(permissions: metadata.permissions);
            },
            icon: Icon(Symbols.add_rounded),
            label: const Text('New Role'),
          );
        },
      ),
    );
  }
}
