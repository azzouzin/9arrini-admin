import 'package:flutter/material.dart';

class PdfTextfield extends StatelessWidget {
  const PdfTextfield(
      {Key? key,
      required this.imageCtrl,
      required this.onClear,
      required this.onPickPDF})
      : super(key: key);

  final TextEditingController imageCtrl;
  final Function onClear;
  final Function onPickPDF;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: imageCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
          hintText: 'Enter PDF Url or Select PDF File',
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
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => onPickPDF(),
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
