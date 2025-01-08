import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageTextField extends StatelessWidget {
  const ImageTextField({
    Key? key,
    required this.imageCtrl,
    required this.onClear,
    required this.onPickImage,
    required this.imageFile,
  }) : super(key: key);

  final TextEditingController imageCtrl;
  final Function onClear;
  final Function onPickImage;
  final XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: imageCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
          hintText: 'Enter Image Url or Select Image',
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
                tooltip: 'Select Image',
                icon: const Icon(Icons.image_outlined),
                onPressed: () => onPickImage(),
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
