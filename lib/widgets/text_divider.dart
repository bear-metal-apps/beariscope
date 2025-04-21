import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const TextDivider({
    super.key,
    this.text = 'or',
    this.thickness = 1,
    this.maxWidth = 300,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider(thickness: thickness)),
          Padding(padding: padding, child: Text(text)),
          Expanded(child: Divider(thickness: thickness)),
        ],
      ),
    );
  }
}
