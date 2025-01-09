import 'package:app_admin/components/category_dropdown.dart';
import 'package:app_admin/components/pdf_textfield.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/forms/question_form/question_audio.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../blocs/years_bloc.dart';
import '../../components/year_dropdown.dart';
import '../../models/test.dart';

class TestForm extends ConsumerStatefulWidget {
  const TestForm({Key? key, required this.q}) : super(key: key);

  final Test? q;

  @override
  ConsumerState<TestForm> createState() => _TestFormState();
}

class _TestFormState extends ConsumerState<TestForm> {
  late String _submitBtnText;
  late String _dialogText;
  final _btnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'tests';

  final HtmlEditorController editorController = HtmlEditorController();

  String? _questionType;

  var questionTitleCtlr = TextEditingController();
  var option1Ctlr = TextEditingController();
  var option2Ctlr = TextEditingController();
  var option3Ctlr = TextEditingController();
  var option4Ctlr = TextEditingController();

  var questionImageCtrl = TextEditingController();
  var questionAudioCtrl = TextEditingController();
  var questionpdfCtrl = TextEditingController();
  var questionVideoCtrl = TextEditingController();

  String? _selectedCategoryId;

  Uint8List? _seletedAudioByte;
  Uint8List? _pdfAudioByte;
  late Future<List<Quiz>> _quizes;
  var option1ImageCtlr = TextEditingController();
  var option2ImageCtlr = TextEditingController();
  var option3ImageCtlr = TextEditingController();
  var option4ImageCtlr = TextEditingController();

  Future _onPickAudio() async {
    FilePickerResult? result = await AppService().pickAudio();
    if (result != null) {
      setState(() {
        _seletedAudioByte = result.files.first.bytes;
        questionAudioCtrl.text = result.files.first.name;
      });
    }
  }

  Future _onPickPDF() async {
    FilePickerResult? result = await AppService().pdfPicker();
    if (result != null) {
      setState(() {
        _pdfAudioByte = result.files.first.bytes;
        questionpdfCtrl.text = result.files.first.name;
      });
    }
  }

  Future<String?> _uploadPdfToFirebaseHosting() async {
    String? pdfUrl;
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('test_pdfs/${questionpdfCtrl.text}');
    final UploadTask uploadTask = storageReference.putData(_pdfAudioByte!);
    await uploadTask.whenComplete(() async {
      pdfUrl = await storageReference.getDownloadURL();
    });
    return pdfUrl;
  }

  initData() {
    // if (widget.q == null) {
    //   _questionType = Constants.questionTypes.keys.elementAt(0);
    //   _quizes = Future.value();
    // } else {
    //   _selectedCategoryId = widget.q?.catId;
    //   _selectedQuizId = widget.q?.quizId;
    //   _quizes = FirebaseService().getCategoryBasedQuizes(widget.q!.catId!);
    //   questionTitleCtlr.text = widget.q!.questionTitle.toString();

    //   _questionType = widget.q!.questionType;
    //   _optionType = _getOptionsTyoe();
    //   if (_getOptionsTyoe() == Constants.optionTypes.keys.elementAt(0)) {
    //     option1Ctlr.text = widget.q!.options![0];
    //     option2Ctlr.text = widget.q!.options![1];
    //     option3Ctlr.text = widget.q!.options![2];
    //     option4Ctlr.text = widget.q!.options![3];
    //   }
    //   if (_getOptionsTyoe() == Constants.optionTypes.keys.elementAt(2)) {
    //     option1ImageCtlr.text = widget.q!.options![0];
    //     option2ImageCtlr.text = widget.q!.options![1];
    //     option3ImageCtlr.text = widget.q!.options![2];
    //     option4ImageCtlr.text = widget.q!.options![3];
    //   }

    //   _correctAnsIndex = widget.q!.correctAnswerIndex!;
    //   questionImageCtrl.text =
    //       widget.q?.questionType == null || widget.q?.questionImageUrl == null
    //           ? ''
    //           : widget.q!.questionImageUrl.toString();
    //   _questionType = widget.q!.questionType;
    //   questionAudioCtrl.text = widget.q!.questionAudioUrl == null
    //       ? ''
    //       : widget.q!.questionAudioUrl.toString();
    //   questionVideoCtrl.text = widget.q!.questionVideoUrl == null
    //       ? ''
    //       : widget.q!.questionVideoUrl.toString();
    // }
  }

  @override
  void initState() {
    _submitBtnText = widget.q == null ? 'Upload Test' : 'Update Test';
    _dialogText =
        widget.q == null ? 'Uploaded Successfully!' : 'Updated Successfully!';
    initData();
    super.initState();
  }

  void _handleSubmit() async {
    if (hasAccess(ref)) {
      if (_selectedCategoryId != null) {
        if (_pdfAudioByte != null) {
          formKey.currentState!.save();
          _uploadPdfToFirebaseHosting().then((String? pdfUrl) async {
            if (pdfUrl != null) {
              _uploadProcedures(pdfUrl);
            }
          });
        }
      } else {
        openCustomDialog(context, 'Select A Category', '');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _uploadProcedures(String link) async {
    //  _btnCtlr.start();
    await uploadTest(link).then((value) async {
      if (widget.q == null) {
        // await await FirebaseService()
        //     .increaseQuestionCountInQuiz(_selectedQuizId!, null);
        // _clearForm();
        // ref.invalidate(questionsCountProvider);
      }
      _btnCtlr.reset();
      print("UPLOADING TEST FINISHED");
      print(value);

      if (!mounted) return;
      openCustomDialog(context, _dialogText, '');
    });
  }

  Future uploadTest(String link) async {
    try {
      final String docId = firestore.collection(collectionName).doc().id;

      var createdAt = widget.q == null ? DateTime.now() : widget.q!.createdAt;
      var updatedAt = widget.q == null ? null : DateTime.now();
      Logger().i('Uploading Test');
      Test q = Test(
        id: docId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: questionpdfCtrl.text,
        link: link,
        year: context.read<YearsBloc>().selctedYear,
      );

      Map<String, dynamic> data = Test.getMap(q);

      await firestore.collection(collectionName).doc(docId).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      Logger().e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: InkWell(
            child: const CircleAvatar(
              radius: 20,
              child: Icon(Icons.close),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              YearDropdown(
                onChanged: (value) {
                  print(value);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Category',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        CategoryDropdown(
                          selectedCategoryId: _selectedCategoryId,
                          onChanged: (value) {
                            _selectedCategoryId = value;
                            _quizes =
                                FirebaseService().getCategoryBasedQuizes(value);
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 20),
              QuestionAudio(
                questionType: _questionType,
                imageCtrl: questionAudioCtrl,
                onClear: () {
                  setState(() => _seletedAudioByte = null);
                },
                onPickAudio: _onPickAudio,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Question PDF',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PdfTextfield(
                    imageCtrl: questionpdfCtrl,
                    onClear: () {
                      setState(() => _pdfAudioByte = null);
                    },
                    onPickPDF: _onPickPDF,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _bottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: RoundedLoadingButton(
        animateOnTap: false,
        borderRadius: 5,
        controller: _btnCtlr,
        onPressed: () => _handleSubmit(),
        color: Theme.of(context).primaryColor,
        elevation: 0,
        child: Wrap(
          children: [
            Text(
              _submitBtnText,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
