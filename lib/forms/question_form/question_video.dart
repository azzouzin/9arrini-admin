import 'package:flutter/material.dart';

import '../../configs/constants.dart';

class QuestionVideo extends StatelessWidget {
  const QuestionVideo({Key? key, required this.questionType, required this.questionVideoCtrl}) : super(key: key);

  final String? questionType;
  final TextEditingController questionVideoCtrl;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: questionType == Constants.questionTypes.keys.elementAt(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              'Question Video Url',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          TextFormField(
            controller: questionVideoCtrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
              hintText: 'Enter Video URL',
              alignLabelWithHint: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  questionVideoCtrl.clear();
                },
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) return 'Value is empty';
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
