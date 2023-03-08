import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final String number;
  final double value;
  const Rating({Key? key, required this.number, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(number,
          style: const TextStyle(
              fontSize: 15
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 180,
          height: 12,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            child: LinearProgressIndicator(
                value: value,
            ),
          ),
        ),
      ],
    );
  }
}
