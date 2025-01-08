import 'package:flutter/material.dart';

import '../../configs/constants.dart';

class QuestionTitle extends StatelessWidget {
  const QuestionTitle({Key? key, required this.questionType}) : super(key: key);

  final String? questionType;

  @override
  Widget build(BuildContext context) {
    return Text(
      questionType != Constants.questionTypes.keys.elementAt(4) ? 'Question Title' : 'Question Title (Add <_> for blank target space)',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
