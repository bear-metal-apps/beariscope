import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSelectionPage extends ConsumerStatefulWidget {
  const UserSelectionPage({super.key});

  @override
  ConsumerState<UserSelectionPage> createState() =>
      _UserSelectionPageState();
}
class _UserSelectionPageState extends ConsumerState<UserSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Selection')),
      body: Center(child: const Text('User Selection')),
    );
  }
}