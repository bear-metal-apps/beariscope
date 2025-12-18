import 'package:flutter/material.dart';

class UpNextWidget extends StatelessWidget {
  final String match;
  final String time;
  final VoidCallback onPressed;

  const UpNextWidget({
    super.key,
    required this.match,
    required this.time,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: BoxConstraints(maxWidth: 800),
        padding: EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(time),
              ],
            ),
            OutlinedButton(onPressed: onPressed, child: Text('Button')),
          ],
        ),
      ),
    );
  }
}
