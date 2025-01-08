import 'package:app_admin/components/image_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../configs/constants.dart';

class QuestionImage extends StatelessWidget {
  const QuestionImage({
    Key? key,
    required this.questionType,
    required this.questionImageCtrl,
    required this.selectedQuestionImage,
    required this.onClear,
    required this.onPickImage,
  }) : super(key: key);

  final String? questionType;
  final TextEditingController questionImageCtrl;
  final XFile? selectedQuestionImage;
  final Function onClear;
  final Function onPickImage;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: questionType == Constants.questionTypes.keys.elementAt(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Image',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          ImageTextField(imageCtrl: questionImageCtrl, onClear: onClear, onPickImage: onPickImage, imageFile: selectedQuestionImage),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
