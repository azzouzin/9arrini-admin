import 'package:app_admin/blocs/years_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

class YearDropdown extends ConsumerWidget {
  const YearDropdown({Key? key, required this.onChanged}) : super(key: key);

  final Function onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(5)),
        child: DropdownButtonFormField<int>(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (int? value) {
              onChanged(value);
            },
            value: context.read<YearsBloc>().selctedYear,
            hint: const Text('Select Year'),
            items: context.read<YearsBloc>().years.map((f) {
              return DropdownMenuItem(
                value: f,
                child: Text(f.toString()),
              );
            }).toList()));
  }
}
