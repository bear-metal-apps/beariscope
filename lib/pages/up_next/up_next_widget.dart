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
        width: MediaQuery.of(context).size.width * 0.6,
        height: 100,
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(20.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        match,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(time, style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,

                child: OutlinedButton(
                  onPressed: onPressed,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Next Event', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
