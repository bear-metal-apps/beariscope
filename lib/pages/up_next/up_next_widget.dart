import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UpNextWidget extends StatelessWidget {
  final String matchKey;
  final String time;

  const UpNextWidget({super.key, required this.matchKey, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/up_next/$matchKey'),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    matchKey,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  Text(time),
                ],
              ),
              // OutlinedButton(onPressed: onPressed, child: Text('Next Event')),
            ],
          ),
        ),
      ),
    );
  }
}
