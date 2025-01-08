import 'package:flutter/material.dart';

class AudioTextfield extends StatelessWidget {
  const AudioTextfield({Key? key, required this.imageCtrl, required this.onClear, required this.onPickAudio}) : super(key: key);

  final TextEditingController imageCtrl;
  final Function onClear;
  final Function onPickAudio;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: imageCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
          hintText: 'Enter Audio Url or Select Audio File',
          alignLabelWithHint: true,
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  imageCtrl.clear();
                  onClear();
                },
              ),
              IconButton(
                tooltip: 'Select Audio File',
                icon: const Icon(Icons.audio_file),
                onPressed: () => onPickAudio(),
              ),
            ],
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Value is empty';
          return null;
        });
  }
}
