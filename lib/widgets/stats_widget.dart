import 'package:flutter/material.dart';
import 'package:mx_companion_v1/config/themes/ui_parameters.dart';

class Stat extends StatelessWidget {
  final String text;
  final String name;
  const Stat({Key? key, required this.text, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      height: 100,
      width: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: UIParameters.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium!.merge(
                const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Text(
              name,
              style: TextStyle(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
