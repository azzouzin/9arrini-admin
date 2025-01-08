import 'package:flutter/material.dart';

InputDecoration inputDecoration(hint, controller) {
  return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.only(right: 0, left: 10),
      suffixIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey[300],
          child: IconButton(
              icon: const Icon(Icons.close, size: 15),
              onPressed: () {
                controller.clear();
              }),
        ),
      ));
}

ButtonStyle buttonStyle(Color? color) {
  return TextButton.styleFrom(
    padding: const EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
    backgroundColor: color,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  );
}

TextStyle defaultTextStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w400);
}
