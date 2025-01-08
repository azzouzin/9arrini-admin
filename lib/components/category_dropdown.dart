import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/categories_provider.dart';

class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({Key? key, required this.selectedCategoryId, required this.onChanged}) : super(key: key);

  final String? selectedCategoryId;
  final Function onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(5)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              onChanged(value);
            },
            value: selectedCategoryId,
            hint: const Text('Select Category'),
            items: categories.map((f) {
              return DropdownMenuItem(
                value: f.id,
                child: Text(f.name!),
              );
            }).toList()));
  }
}
