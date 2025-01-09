import 'package:app_admin/components/image_preview.dart';
import 'package:app_admin/forms/question_form/test_form.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../configs/config.dart';
import '../forms/quiz_form.dart';
import '../models/test.dart';
import '../services/firebase_service.dart';
import '../utils/cached_image.dart';
import '../utils/custom_dialog.dart';
import '../utils/styles.dart';
import 'custom_dialogs.dart';

class TestDataSource extends DataTableSource {
  final List<Test> testList;
  final BuildContext context;
  final WidgetRef ref;

  TestDataSource(this.context, this.testList, this.ref);

  final String collectionName = 'tests';
  final _deleteBtnCtlr = RoundedLoadingButtonController();

  _handleDelete(Test d) async {
    _deleteBtnCtlr.start();
    await _onDelete(d).then((value) {
      _deleteBtnCtlr.reset();
      if (!context.mounted) return;
      Navigator.pop(context);
      openCustomDialog(context, 'Deleted Successfully!', '');
    });
  }

  Future _onDelete(Test d) async {
    await FirebaseService().deleteContent(collectionName, d.id!);
    // await FirebaseService().decreaseQuizCountInCategory(d.parentId!);
    // await FirebaseService().deleteRelatedQuestionsAssociatedWithQuiz(d.id!);
  }

  _onDeletePressed(Test d) async {
    if (hasAdminAccess(ref)) {
      _openDeteleDialog(context, d);
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  void _openDeteleDialog(context, Test d) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Delete This Test?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text(
                  "Do you want to delete this test and it's contents?\nWarning: All of the questions included to this test will be deleted too!",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: _deleteBtnCtlr,
                    color: Colors.redAccent,
                    onPressed: () => _handleDelete(d),
                    child: const Text(
                      'Yes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: RoundedLoadingButtonController(),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(cells: [
      DataCell(
        Text(
          testList[index].name.toString(),
        ),
      ),
      DataCell(Text(
        testList[index].year.toString(),
        style: defaultTextStyle(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      )),
      DataCell(Text(
        testList[index].createdAt.toString(),
        style: defaultTextStyle(context),
      )),
      // DataCell(
      //   FutureBuilder(
      //     future: FirebaseService().getCategoryName(testList[index].name!),
      //     builder: (BuildContext context, AsyncSnapshot snapshot) {
      //       if (snapshot.hasData) {
      //         return Text(
      //           snapshot.data,
      //           style: defaultTextStyle(context),
      //         );
      //       }
      //       return const Text('---');
      //     },
      //   ),
      // ),
      DataCell(_actions(testList[index])),
    ], index: index);
  }

  Row _actions(Test quiz) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          child: IconButton(
            alignment: Alignment.center,
            iconSize: 16,
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => CustomDialogs.openResponsiveDialog(
              context,
              widget: TestForm(q: quiz),
              horizontalPaddingPercentage: 0.15,
              verticalPaddingPercentage: 0.05,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.redAccent,
          child: IconButton(
            iconSize: 16,
            tooltip: 'Delete',
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () => _onDeletePressed(quiz),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => testList.length;

  @override
  int get selectedRowCount => 0;
}
