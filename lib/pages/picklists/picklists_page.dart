import 'package:beariscope/pages/main_view.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/permissions_provider.dart';
import 'package:libkoala/ui/widgets/text_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class PicklistsPage extends ConsumerStatefulWidget {
  const PicklistsPage({super.key});

  @override
  ConsumerState<PicklistsPage> createState() {
    return PicklistsPageState();
  }
}

class PicklistsPageState extends ConsumerState<PicklistsPage> {
  final TextEditingController joinCodeTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    final permissionChecker = ref.watch(permissionCheckerProvider);
    final canCreatePicklists =
        permissionChecker?.hasPermission(PermissionKey.picklistsManage) ??
        false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picklists'),
        leading:
            controller.isDesktop
                ? null
                : IconButton(
                  icon: const Icon(Symbols.menu_rounded),
                  onPressed: controller.openDrawer,
                ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter join code',
                ),
                controller: joinCodeTEC,
              ),
            ),
            SizedBox(height: 12),
            FilledButton(onPressed: () {}, child: Text('Join')),
            SizedBox(height: 20),
            TextDivider(maxWidth: 150),
            SizedBox(height: 20),
            if (canCreatePicklists)
              FilledButton(
                onPressed: () => context.push('/picklists/create'),
                child: Text('Create'),
              ),
            SizedBox(height: 62),
          ],
        ),
      ),
    );
  }
}
