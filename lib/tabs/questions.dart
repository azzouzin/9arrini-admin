import 'package:app_admin/forms/question_form/import_questions/import_questions.dart';
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
import '../components/question_data_source.dart';
import '../forms/question_form/question_form.dart';
import '../models/question.dart';

class Questions extends ConsumerStatefulWidget {
  const Questions({Key? key}) : super(key: key);

  @override
  ConsumerState<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends ConsumerState<Questions> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'questions';
  final int _itemPerPage = 11;
  String? _sortByText;

  late Query<Map<String, dynamic>> query;

  @override
  void initState() {
    _sortByText = 'Newest First';
    query = firestore.collection(collectionName).orderBy('created_at', descending: true);
    super.initState();
  }

  final List<DataColumn> _columns = [
    const DataColumn(
      label: Text('Question Title'),
    ),
    const DataColumn(
      label: Text('Options'),
    ),
    const DataColumn(
      label: Text('Question Type'),
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
            List<Question> qList = [];
            qList = snapshot.docs.map((e) => Question.fromFirestore(e)).toList();
            DataTableSource source = QuestionDataSource(context, qList, ref);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PaginatedDataTable2(
                rowsPerPage: _itemPerPage - 1,
                source: source,
                header: Text('All Questions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                empty: const Center(child: Text('No Questions Found')),
                minWidth: 900,
                wrapInCard: false,
                horizontalMargin: 20,
                columnSpacing: 20,
                dataRowHeight: 90,
                onPageChanged: (_) {
                  snapshot.fetchMore();
                },
                actions: [
                  CustomButtons.customOutlineButton(
                    context,
                    icon: Icons.add,
                    text: 'Add Question',
                    bgColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    onPressed: () => CustomDialogs.openResponsiveDialog(
                      context,
                      widget: const QuestionForm(q: null),
                      horizontalPaddingPercentage: 0.15,
                      verticalPaddingPercentage: 0.05,
                    ),
                  ),
                  CustomButtons.customOutlineButton(
                    context,
                    icon: Icons.file_upload,
                    text: 'Import Questions',
                    bgColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    onPressed: () => CustomDialogs.openResponsiveDialog(
                      context,
                      widget: const BulkUpload(),
                      horizontalPaddingPercentage: 0.08,
                      verticalPaddingPercentage: 0.03,
                    ),
                  ),
                  _sortButton(),
                ],
                columns: _columns,
                fixedTopRows: 1,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sortButton() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.sort_down,
              color: Colors.grey[800],
            ),
            Visibility(
              visible: Responsive.isMobile(context) ? false : true,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Sort By - $_sortByText',
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          const PopupMenuItem(
            value: 'new',
            child: Text('Newest First'),
          ),
          const PopupMenuItem(
            value: 'old',
            child: Text('Oldest First'),
          ),
          const PopupMenuItem(
            value: 'four',
            child: Text('Four Options'),
          ),
          const PopupMenuItem(
            value: 'tf',
            child: Text('True/False'),
          ),
          const PopupMenuItem(
            value: 'text',
            child: Text('Text Only Questions'),
          ),
          const PopupMenuItem(
            value: 'image',
            child: Text('Image Questions'),
          ),
          const PopupMenuItem(
            value: 'audio',
            child: Text('Audio Questions'),
          ),
          const PopupMenuItem(
            value: 'video',
            child: Text('Video Questions'),
          ),
          const PopupMenuItem(
            value: 'fill_blanks',
            child: Text('Fill Blanks Questions'),
          ),
          const PopupMenuItem(
            value: 'quiz',
            child: Text('Sort By Quiz'),
          ),
          const PopupMenuItem(
            value: 'category',
            child: Text('Sort By Category'),
          ),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'new') {
          setState(() {
            _sortByText = 'Newest First';
            query = firestore.collection(collectionName).orderBy('created_at', descending: true);
          });
        } else if (value == 'old') {
          setState(() {
            _sortByText = 'Oldest First';
            query = firestore.collection(collectionName).orderBy('created_at', descending: false);
          });
        } else if (value == 'four') {
          setState(() {
            _sortByText = 'Four Options';
            query = firestore.collection(collectionName).where('has_four_options', isEqualTo: true);
          });
        } else if (value == 'tf') {
          setState(() {
            _sortByText = 'True/False';
            query = firestore.collection(collectionName).where('has_four_options', isEqualTo: false);
          });
        } else if (value == 'text') {
          setState(() {
            _sortByText = 'Text Only';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(0));
          });
        } else if (value == 'image') {
          setState(() {
            _sortByText = 'Image Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(1));
          });
        } else if (value == 'audio') {
          setState(() {
            _sortByText = 'Audio Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(2));
          });
        } else if (value == 'video') {
          setState(() {
            _sortByText = 'Video Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(3));
          });
        } else if (value == 'fill_blanks') {
          setState(() {
            _sortByText = 'Fill Blanks Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(4));
          });
        } else if (value == 'quiz') {
          _openQuizDialog();
        } else if (value == 'category') {
          _openCategoryDialog();
        }
      },
    );
  }

  _openQuizDialog() async {
    await FirebaseService().getQuizes().then((List<Quiz> qList) {
      if(!mounted) return;
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
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text('${index + 1}. ${qList[index].name!}'),
                      onTap: () {
                        setState(() {
                          _sortByText = qList[index].name!;
                          query = firestore.collection('questions').where('quiz_id', isEqualTo: qList[index].id);
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
      if(!mounted) return;
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
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text('${index + 1}. ${cList[index].name!}'),
                      onTap: () {
                        setState(() {
                          _sortByText = cList[index].name!;
                          query = firestore.collection('questions').where('cat_id', isEqualTo: cList[index].id);
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
