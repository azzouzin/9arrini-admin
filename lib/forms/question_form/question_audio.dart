import 'package:app_admin/components/audio_textfield.dart';
import 'package:flutter/material.dart';
import '../../configs/constants.dart';

class QuestionAudio extends StatelessWidget {
  const QuestionAudio({Key? key, required this.questionType, required this.imageCtrl, required this.onClear, required this.onPickAudio}) : super(key: key);

  final String? questionType;
  final TextEditingController imageCtrl;
  final Function onClear;
  final Function onPickAudio;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: questionType == Constants.questionTypes.keys.elementAt(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              'Question Audio',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          AudioTextfield(
            imageCtrl: imageCtrl,
            onClear: onClear,
            onPickAudio: onPickAudio,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
