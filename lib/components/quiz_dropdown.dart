import 'package:app_admin/models/quiz.dart';
import 'package:flutter/material.dart';

class QuizDropdown extends StatelessWidget {
  const QuizDropdown({Key? key, required this.seletedQuizId, required this.onChanged, required this.quizzes}) : super(key: key);

  final String? seletedQuizId;
  final Function onChanged;
  final List<Quiz> quizzes;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(5)),
        child: DropdownButtonFormField(
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) => onChanged(value),
            value: seletedQuizId,
            hint: const Text('Select Quiz Name'),
            items: quizzes.map((f) {
              return DropdownMenuItem(
                value: f.id,
                child: Wrap(
                  children: [Text(f.name.toString())],
                ),
              );
            }).toList()));
  }
}
