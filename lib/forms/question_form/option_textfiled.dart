import 'package:flutter/material.dart';

class OptionTextField extends StatelessWidget {
  const OptionTextField({
    Key? key,
    required this.textController,
    required this.title,
    this.isReadOnly = false,
    this.hintText = 'Enter Option Name',
    this.hasValidation = true,
  }) : super(key: key);

  final TextEditingController textController;
  final String title;
  final bool isReadOnly;
  final String hintText;
  final bool hasValidation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        TextFormField(
          readOnly: isReadOnly,
          controller: isReadOnly ? null : textController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
            hintText: hintText,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => textController.clear(),
            ),
          ),
          validator: (value) {
            if (hasValidation) {
              if (value!.isEmpty) return 'Value is empty';
            }
            return null;
          },
        ),
      ],
    );
  }
}
