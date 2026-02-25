import 'package:beariscope/pages/main_view.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/ui/widgets/text_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hive_ce_flutter/adapters.dart';

class PicklistsPage extends ConsumerStatefulWidget {
  const PicklistsPage({super.key});

  @override
  ConsumerState<PicklistsPage> createState() {
    return PicklistsPageState();
  }
}

class PicklistsPageState extends ConsumerState<PicklistsPage> {
  final TextEditingController joinCodeTEC = TextEditingController();

  Future<void> _joinPicklist() async {
    final joinCode = joinCodeTEC.text.trim();
    if (joinCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a join code')),
      );
      return;
    }

    try {
      final box = await Hive.openBox('picklists');
      Map<String, dynamic>? foundPicklist;

      // Search for picklist by password
      for (final value in box.values) {
        final picklistMap = Map<String, dynamic>.from(value as Map);
        if (picklistMap['password'] == joinCode) {
          foundPicklist = picklistMap;
          break;
        }
      }
      
      await box.close();

      if (foundPicklist != null) {
        if (mounted) {
          context.push('/picklists/view', extra: foundPicklist);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Picklist not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
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
                obscureText: true,
              ),
            ),
            SizedBox(height: 12),
            FilledButton(
              onPressed: _joinPicklist,
              child: const Text('Join'),
            ),
            SizedBox(height: 20),
            TextDivider(maxWidth: 150),
            SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.push('/picklists/create'),
              child: const Text('Create'),
            ),
            SizedBox(height: 62),
          ],
        ),
      ),
    );
  }
}
