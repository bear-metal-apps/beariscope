import 'dart:convert';

import 'package:flutter/material.dart';

class UiCreatorPage extends StatelessWidget {
  const UiCreatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    JsonDecoder matchJson = JsonDecoder();

    return Scaffold(
      appBar: AppBar(title: const Text('UI Creator'), actions: []),
      body: Row(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start),
          Column(mainAxisAlignment: MainAxisAlignment.end),
        ],
      ),
    );
  }
}
