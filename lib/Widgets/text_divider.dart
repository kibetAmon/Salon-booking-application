import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String text;
  final double height;
  final Color color;

  const TextDivider({
   required this.text,
    required this.height,
    required this.color
});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Divider(
            color: color,
          ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Divider(
                color: color,
              ),
          ),
        ],
      ),
    );
  }
}