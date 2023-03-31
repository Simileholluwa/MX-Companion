import 'package:flutter/material.dart';
import 'package:mx_companion_v1/widgets/questions/answer_card.dart';

import '../../config/themes/ui_parameters.dart';

class QuestionAnswerCard extends StatelessWidget {
  final int index;
  final AnswerStatus? status;
  final VoidCallback onTap;
  final bool addSplash;
  const QuestionAnswerCard({Key? key, required this.index, this.status, required this.onTap, this.addSplash = false,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColorr = Theme.of(context).colorScheme.background;
    switch(status) {
      case AnswerStatus.answered:
        backgroundColorr = Colors.green;
        break;

      case AnswerStatus.wrong:
        backgroundColorr = Colors.red.shade900;
        break;

      case AnswerStatus.correct:
        backgroundColorr = Colors.green;
        break;

      case AnswerStatus.notAnswered:
        backgroundColorr = Colors.red.shade700;
        break;

      default:
        backgroundColorr = Colors.red.shade700;
    }
    return Material(
      borderRadius: UIParameters.cardBorderRadius,
      child: InkWell(
        borderRadius: UIParameters.cardBorderRadius,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(10),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
              borderRadius: UIParameters.cardBorderRadius
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 20,
                color: backgroundColorr,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
