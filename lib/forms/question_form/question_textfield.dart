import 'package:flutter/material.dart';

import '../../configs/constants.dart';

class QuestionTextField extends StatelessWidget {
  const QuestionTextField({Key? key, required this.questionTitleCtlr, required this.questionType}) : super(key: key);

  final TextEditingController questionTitleCtlr;
  final String? questionType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: questionTitleCtlr,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
          hintText: 'Enter Question',
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => questionTitleCtlr.clear(),
          )),
      validator: (value) {
        if (value!.isEmpty) return 'Value is empty';
        if (questionType == Constants.questionTypes.keys.elementAt(4)) {
          if (!value.contains('<_>')) return 'Blank target space is not added';
        }
        return null;
      },
    );
  }
}
