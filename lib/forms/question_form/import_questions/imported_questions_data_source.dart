import 'package:app_admin/models/import_question.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:flutter/material.dart';
import '../../../components/image_preview.dart';
import '../../../configs/constants.dart';
import '../../../utils/cached_image.dart';
import '../../../utils/styles.dart';

class ImportedQuestionsDataSource extends DataTableSource {
  final List<ImportQuestion> questions;
  final BuildContext context;

  ImportedQuestionsDataSource(this.context, this.questions);

  @override
  DataRow getRow(int index) {
    final ImportQuestion question = questions[index];
    return DataRow.byIndex(cells: [
      DataCell(Text(
        questions[index].question,
        style: defaultTextStyle(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      )),
      _options(question),
      DataCell(Text(question.correctAnswerIndex.toString())),
      DataCell(Text(question.questionType.toString())),
      DataCell(Text(question.optionType.toString())),
      _explanation(question),
      _questionImage(question.questionImageURL ?? ''),
      _questionAudio(question.questionAudioURL ?? ''),
      _questionVideo(question.questionVideoURL ?? ''),
    ], index: index);
  }

  DataCell _explanation(ImportQuestion question) {
    return DataCell(
      Text(AppService.getNormalText(question.explanation ?? ''), maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }

  DataCell _questionImage(String imageUrl) {
    if (imageUrl.isEmpty) return const DataCell(SizedBox.shrink());
    return DataCell(
      InkWell(
        onTap: () => openImagePreview(context, imageUrl),
        child: Container(
          margin: const EdgeInsets.all(5),
          height: 30,
          width: 40,
          child: CustomCacheImage(imageUrl: imageUrl, radius: 2),
        ),
      ),
    );
  }

  DataCell _questionAudio(String audioURL) {
    if (audioURL.isEmpty) return const DataCell(SizedBox.shrink());
    return DataCell(
      InkWell(
        onTap: () => AppService().openLink(context, audioURL),
        child: const CircleAvatar(child: Icon(Icons.audio_file)),
      ),
    );
  }

  DataCell _questionVideo(String videoURl) {
    if (videoURl.isEmpty) return const DataCell(SizedBox.shrink());
    return DataCell(
      InkWell(
        onTap: () => AppService().openLink(context, videoURl),
        child: const CircleAvatar(child: Icon(Icons.play_circle)),
      ),
    );
  }

  DataCell _options(ImportQuestion q) {
    if (q.optionType == '' || q.optionType == Constants.optionTypes.keys.elementAt(0) || q.optionType == Constants.optionTypes.keys.elementAt(1)) {
      return DataCell(Text(
        q.options.toString(),
        style: defaultTextStyle(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ));
    } else if (q.optionType == Constants.optionTypes.keys.elementAt(2)) {
      return DataCell(Wrap(
          children: q.options
              .map((e) => InkWell(
                    onTap: () => openImagePreview(context, e),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      height: 30,
                      width: 40,
                      child: CustomCacheImage(imageUrl: e, radius: 2),
                    ),
                  ))
              .toList()));
    } else {
      return DataCell(Container());
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => questions.length;

  @override
  int get selectedRowCount => 0;
}
