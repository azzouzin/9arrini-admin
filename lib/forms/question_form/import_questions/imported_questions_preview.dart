import 'package:app_admin/forms/question_form/import_questions/imported_questions_data_source.dart';
import 'package:app_admin/models/import_question.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class ImportedQuestionsPreview extends StatelessWidget {
  ImportedQuestionsPreview({Key? key, required this.questions}) : super(key: key);

  final List<ImportQuestion> questions;

  final int _itemPerPage = 11;

  final List<DataColumn> _columns = [
    const DataColumn(
      label: Text('Title'),
    ),
    const DataColumn(
      label: Text('Options'),
    ),
    const DataColumn(
      label: Text('Correct Answer Index'),
    ),
    const DataColumn(
      label: Text('Question Type'),
    ),
    const DataColumn(
      label: Text('Option Type'),
    ),
    const DataColumn(
      label: Text('Explantion'),
    ),
    const DataColumn(
      label: Text('Question Image URL'),
    ),
    const DataColumn(
      label: Text('Question Audio URL'),
    ),
    const DataColumn(
      label: Text('Question Video URL'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    DataTableSource source = ImportedQuestionsDataSource(context, questions);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PaginatedDataTable2(
        rowsPerPage: _itemPerPage - 1,
        source: source,
        header:
            Text('Questions Imported (${questions.length})', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
        empty: const Center(child: Text('No Questions Found')),
        minWidth: 900,
        wrapInCard: false,
        horizontalMargin: 20,
        columnSpacing: 20,
        dataRowHeight: 90,
        renderEmptyRowsInTheEnd: false,
        columns: _columns,
        fixedTopRows: 1,
      ),
    );
  }
}
