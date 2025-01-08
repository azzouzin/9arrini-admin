import 'package:app_admin/models/question.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../components/html_editor.dart';

class QuestionExplanation extends StatelessWidget {
  const QuestionExplanation({Key? key, required this.editorController, required this.q}) : super(key: key);

  final HtmlEditorController editorController;
  final Question? q;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            'Explaination (Optional)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
            decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(width: 2, color: Colors.grey[300]!)),
            child: CustomHtmlEditor(
              controller: editorController,
              initialText: q == null || q?.explaination == null ? '' : q!.explaination.toString(),
            )),
      ],
    );
  }
}
