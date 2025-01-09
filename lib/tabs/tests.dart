import 'package:app_admin/components/card_wrapper.dart';
import 'package:app_admin/components/custom_buttons.dart';
import 'package:app_admin/components/custom_dialogs.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/models/category.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../forms/question_form/import_questions/import_questions.dart';
import '../forms/question_form/test_form.dart';
import '../models/Test.dart';

class Tests extends ConsumerStatefulWidget {
  const Tests({Key? key}) : super(key: key);

  @override
  ConsumerState<Tests> createState() => _TestsState();
}

class _TestsState extends ConsumerState<Tests> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'tests';
  final int _itemPerPage = 11;
  String? _sortByText;

  late Query<Map<String, dynamic>> query;

  @override
  void initState() {
    _sortByText = 'Newest First';
    query = firestore
        .collection(collectionName)
        .orderBy('created_at', descending: true);
    super.initState();
  }

  final List<DataColumn> _columns = [
    const DataColumn(
      label: Text('Test Title'),
    ),
    const DataColumn(
      label: Text('Options'),
    ),
    const DataColumn(
      label: Text('Test Type'),
    ),
    const DataColumn(
      label: Text('Quiz Name'),
    ),
    const DataColumn(
      label: Text('Actions'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardWrapper(
        child: FirestoreQueryBuilder<Map<String, dynamic>>(
          pageSize: _itemPerPage,
          query: query,
          builder: (context, snapshot, _) {
            List<Test> qList = [];
            qList = snapshot.docs.map((e) => Test.fromFirestore(e)).toList();
            // DataTableSource source =  DataTableSource();
            // TestDataSource(context, qList, ref);
            return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:

                    //  PaginatedDataTable2(
                    //   rowsPerPage: _itemPerPage - 1,
                    //   source: source,
                    //   header: Text('All Tests',
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .headlineSmall
                    //           ?.copyWith(fontWeight: FontWeight.w600)),
                    //   empty: const Center(child: Text('No Tests Found')),
                    //   minWidth: 900,
                    //   wrapInCard: false,
                    //   horizontalMargin: 20,
                    //   columnSpacing: 20,
                    //   dataRowHeight: 90,
                    //   onPageChanged: (_) {
                    //     snapshot.fetchMore();
                    //   },
                    //   actions: [

                    //     _sortButton(),
                    //   ],
                    //   columns: _columns,
                    //   fixedTopRows: 1,
                    // ),
                    Column(children: [
                  CustomButtons.customOutlineButton(
                    context,
                    icon: Icons.add,
                    text: 'Add Test',
                    bgColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    onPressed: () => CustomDialogs.openResponsiveDialog(
                      context,
                      widget: const TestForm(q: null),
                      horizontalPaddingPercentage: 0.15,
                      verticalPaddingPercentage: 0.05,
                    ),
                  ),
                ]));
          },
        ),
      ),
    );
  }

  _openQuizDialog() async {
    await FirebaseService().getQuizes().then((List<Quiz> qList) {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select Quiz'),
              content: SizedBox(
                height: 300,
                width: 300,
                child: ListView.separated(
                  itemCount: qList.length,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text('${index + 1}. ${qList[index].name!}'),
                      onTap: () {
                        setState(() {
                          _sortByText = qList[index].name!;
                          query = firestore
                              .collection('Tests')
                              .where('quiz_id', isEqualTo: qList[index].id);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          });
    });
  }

  _openCategoryDialog() async {
    await FirebaseService().getCategories().then((List<Category> cList) {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select Category'),
              content: SizedBox(
                height: 300,
                width: 300,
                child: ListView.separated(
                  itemCount: cList.length,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text('${index + 1}. ${cList[index].name!}'),
                      onTap: () {
                        setState(() {
                          _sortByText = cList[index].name!;
                          query = firestore
                              .collection('Tests')
                              .where('cat_id', isEqualTo: cList[index].id);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          });
    });
  }
}
