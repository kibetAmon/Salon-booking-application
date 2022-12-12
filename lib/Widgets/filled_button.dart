import 'package:flutter/material.dart';

class FilledButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color fillColor;
  final int width, height;
// Constructor
  const FilledButton({super.key,
    required this.text,
    required this.onPressed,
    this.fillColor = Colors.black,
    this.width = 300,
    this.height = 45,
});

  @override
  Widget build(final BuildContext context){
    return Container(
      width: width.toDouble(),
      height: height.toDouble(),
      child: MaterialButton(
        color: fillColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: onPressed(),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

}