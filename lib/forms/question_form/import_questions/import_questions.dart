import 'dart:convert';
import 'package:app_admin/components/category_dropdown.dart';
import 'package:app_admin/components/quiz_dropdown.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/forms/question_form/import_questions/imported_questions_preview.dart';
import 'package:app_admin/models/question.dart';
import 'package:app_admin/providers/dashboard_providers.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../../configs/constants.dart';
import '../../../../models/quiz.dart';
import '../../../../services/firebase_service.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../models/import_question.dart';
import '../../../providers/user_role_provider.dart';

class BulkUpload extends ConsumerStatefulWidget {
  const BulkUpload({Key? key}) : super(key: key);

  @override
  ConsumerState<BulkUpload> createState() => _BulkUploadState();
}

class _BulkUploadState extends ConsumerState<BulkUpload> {
  late String _selectButtonText;
  final btnCtlr = RoundedLoadingButtonController();
  String? _selectedCategoryId;
  late Future _quizes;
  String? _selectedQuizId;
  List<ImportQuestion> _questions = [];

  _onSelectFile() async {
    FilePickerResult? result = await AppService().pickCSVFile();
    if (result != null && result.files.isNotEmpty) {
      _selectButtonText = result.files.first.name;
      Uint8List uint8list = result.files.first.bytes!;
      String csvFileString = String.fromCharCodes(uint8list);

      List<ImportQuestion> questions = await _getCSVQuestions(csvFileString).catchError((e) {
        return List<ImportQuestion>.empty();
      });

      if (questions.isNotEmpty) {
        debugPrint(questions.length.toString());
        _questions = questions;
        setState(() {});
      } else {
        if (!mounted) return;
        debugPrint('no questions found');
        openCustomDialog(context, 'Error on processing file data', '');
      }
    } else {
      debugPrint('not selected');
    }
  }

  _onClear() {
    _selectButtonText = 'Select File';
    setState(() {});
  }

  _handleBulkUpload() async {
    if (hasAccess(ref)) {
      if (_selectedCategoryId != null && _selectedQuizId != null) {
        if (_questions.isNotEmpty) {
          btnCtlr.start();
          final bool isUploaded = await _handleUploadQuestions(_questions);
          if (isUploaded) {
            await FirebaseService().increaseQuestionCountInQuiz(_selectedQuizId!, _questions.length);
            btnCtlr.success();
            ref.invalidate(questionsCountProvider);
            if (!mounted) return;
            openCustomDialog(context, 'Uploaded ${_questions.length} Questions Successfully!', '');
          } else {
            btnCtlr.reset();
            if (!mounted) return;
            openCustomDialog(context, 'Error on uploading questions to database', '');
          }
        } else {
          openCustomDialog(context, 'No questions found', '');
        }
      } else {
        openCustomDialog(context, 'Select Category & Quiz First', '');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  bool _optionTypeValid(List options, String optionType) {
    bool valid = false;
    if (options.every((element) => element is String)) {
      if (optionType == Constants.optionTypes.keys.elementAt(0)) {
        //text_only
        if (options.length == 4) {
          valid = true;
        } else {
          valid = false;
        }
      }
      if (optionType == Constants.optionTypes.keys.elementAt(1)) {
        //t/f
        if (options.length == 2) {
          valid = true;
        } else {
          valid = false;
        }
      }
      if (optionType == Constants.optionTypes.keys.elementAt(2)) {
        //images
        if (options.length == 4 && options.every((element) => AppService.isURLValid(element) == true)) {
          valid = true;
        } else {
          valid = false;
        }
      }
    } else {
      valid = false;
    }

    return valid;
  }

  bool _questionTypeValid(String questionType, List options, String? image, String? audio, String? video, String questionTitle) {
    bool valid = false;

    if (questionType == Constants.questionTypes.keys.elementAt(0)) {
      // text_only (auto validated)
      valid = true;
    }
    if (questionType == Constants.questionTypes.keys.elementAt(1)) {
      //text_with_image
      if (image != null && AppService.isURLValid(image)) {
        valid = true;
      } else {
        valid = false;
      }
    }
    if (questionType == Constants.questionTypes.keys.elementAt(2)) {
      //audio
      if (audio != null && AppService.isURLValid(audio)) {
        valid = true;
      } else {
        valid = false;
      }
    }
    if (questionType == Constants.questionTypes.keys.elementAt(3)) {
      //video
      if (video != null && AppService.isURLValid(video)) {
        valid = true;
      } else {
        valid = false;
      }
    }
    if (questionType == Constants.questionTypes.keys.elementAt(4)) {
      //fill in the blanks
      if (questionTitle.isNotEmpty && questionTitle.contains('<_>')) {
        valid = true;
      } else {
        valid = false;
      }
    }
    return valid;
  }

  Future<List<ImportQuestion>> _getCSVQuestions(String csvFileString) async {
    List<ImportQuestion> csvQuestions = [];
    final List<List<dynamic>> csvList = const CsvToListConverter().convert(utf8.decode(csvFileString.codeUnits));
    debugPrint(csvList.length.toString());

    for (int i = 1; i < csvList.length; i++) {
      //Skipping the header row
      List<dynamic> row = csvList[i];

      final question = row[0];
      final options = row[1].split('|');
      final correctAnswerIndex = row[2];
      final questionType = row[3];
      final optionType = row[4];
      String? imageURL = row[5];
      String? audioURL = row[6];
      String? videoURL = row[7];
      String? explanation = row[8];

      if (question is String &&
          options is List<String> &&
          Constants.questionTypes.containsKey(questionType) &&
          _questionTypeValid(questionType, options, imageURL, audioURL, videoURL, question) &&
          Constants.optionTypes.containsKey(optionType) &&
          _optionTypeValid(options, optionType) &&
          correctAnswerIndex is int &&
          correctAnswerIndex >= 0 &&
          correctAnswerIndex < options.length) {
        ImportQuestion q = ImportQuestion(
          question: question,
          options: options,
          correctAnswerIndex: correctAnswerIndex,
          questionType: questionType,
          optionType: optionType,
          explanation: explanation,
          questionImageURL: imageURL,
          questionAudioURL: audioURL,
          questionVideoURL: videoURL,
        );
        csvQuestions.add(q);
      }
    }
    return csvQuestions;
  }

  Future<bool> _handleUploadQuestions(List<ImportQuestion> importedQuestions) async {
    List<Question> questions = [];
    for (var question in importedQuestions) {
      final String id = FirebaseService.getUID('questions');
      final createdAt = DateTime.now();
      String? explanation = question.explanation == "" ? null : question.explanation;
      Question q = Question(
        id: id,
        catId: _selectedCategoryId,
        createdAt: createdAt,
        updatedAt: null,
        questionTitle: question.question,
        quizId: _selectedQuizId,
        options: question.options,
        correctAnswerIndex: question.correctAnswerIndex,
        questionType: question.questionType,
        questionImageUrl: question.questionImageURL,
        questionAudioUrl: question.questionAudioURL,
        questionVideoUrl: question.questionVideoURL,
        explaination: explanation,
        optionsType: question.optionType,
      );

      questions.add(q);
    }

    try {
      await FirebaseService().uploadBulkQuestions(questions);
      return true;
    } catch (e) {
      debugPrint('Error on writing batch upload questions: $e');
      return false;
    }
  }

  @override
  void initState() {
    _selectButtonText = 'Select File';
    _quizes = Future.value();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black)),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: _submitButton(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Questions (Bulk Upload)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const Divider(),
            const SizedBox(height: 50),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ' Category',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      CategoryDropdown(
                        selectedCategoryId: _selectedCategoryId,
                        onChanged: (value) {
                          _selectedCategoryId = value;
                          _quizes = FirebaseService().getCategoryBasedQuizes(value);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ' Quiz',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      FutureBuilder(
                        future: _quizes,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            List<Quiz> quizes = snapshot.data ?? [];
                            return QuizDropdown(
                              seletedQuizId: _selectedQuizId,
                              quizzes: quizes,
                              onChanged: (value) {
                                _selectedQuizId = value;
                                setState(() {});
                              },
                            );
                          }

                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _questions.isNotEmpty
                ? SizedBox(
                    height: 600,
                    child: ImportedQuestionsPreview(questions: _questions),
                  )
                : _selectFileContainer(context)
          ],
        ),
      ),
    );
  }

  Column _selectFileContainer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select File (CSV)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        RichText(
          text: TextSpan(text: 'Only CSV files are supported. Please follow the ', style: Theme.of(context).textTheme.bodyMedium, children: [
            TextSpan(
                text: 'instructions',
                recognizer: TapGestureRecognizer()..onTap = () => AppService().openLink(context, 'https://docs.quizhour.mrb-lab.com/customization/import-questions'),
                style: const TextStyle(decoration: TextDecoration.underline, color: Colors.purple)),
            const TextSpan(text: ' and download our demo templates before uploading any files.')
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: DottedBorder(
            color: Colors.grey.shade300,
            dashPattern: const [10, 5],
            child: SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), padding: const EdgeInsets.all(20)),
                    child: Text(_selectButtonText),
                    onPressed: () => _onSelectFile(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Visibility(visible: _questions.isNotEmpty, child: IconButton(onPressed: () => _onClear(), icon: const Icon(Icons.clear)))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding _submitButton() => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: RoundedLoadingButton(
          borderRadius: 0,
          elevation: 0,
          color: Theme.of(context).primaryColor,
          controller: btnCtlr,
          animateOnTap: false,
          onPressed: () => _handleBulkUpload(),
          child: Text(
            'Upload',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      );
}
