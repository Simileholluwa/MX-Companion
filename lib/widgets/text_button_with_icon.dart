import 'package:flutter/material.dart';

class TextButtonWithIcon extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData? icon;
  const TextButtonWithIcon({Key? key, required this.onTap, required this.text, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon ?? Icons.arrow_forward_ios,
        size: 20,
      ),
      label: Text(
        text,
      ),
    );
  }
}
