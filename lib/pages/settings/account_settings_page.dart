import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:libkoala/providers/api_key_provider.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/providers/graphql_provider.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final result = await ref
                  .read(graphqlProvider)
                  .query(
                    QueryOptions(
                      document: gql("""
                        query {
                          team(teamKey: "frc2046") {
                            rookieYear
                          }
                        }
                   """),
                    ),
                  );
              print(result.data?['team']['rookieYear']);
            } catch (e) {
              print('Unexpected error: $e');
            }
          },
          child: const Text('Get Team Data'),
        ),
      ),
    );
  }
}
