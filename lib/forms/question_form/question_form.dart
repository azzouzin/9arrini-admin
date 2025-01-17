import 'package:app_admin/components/category_dropdown.dart';
import 'package:app_admin/components/quiz_dropdown.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/forms/question_form/import_questions/question_image.dart';
import 'package:app_admin/forms/question_form/option_textfiled.dart';
import 'package:app_admin/forms/question_form/question_audio.dart';
import 'package:app_admin/forms/question_form/question_explanation.dart';
import 'package:app_admin/forms/question_form/question_title.dart';
import 'package:app_admin/forms/question_form/question_video.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/providers/dashboard_providers.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../components/image_textfield.dart';
import '../../configs/constants.dart';
import '../../models/question.dart';
import 'question_textfield.dart';

class QuestionForm extends ConsumerStatefulWidget {
  const QuestionForm({Key? key, required this.q}) : super(key: key);

  final Question? q;

  @override
  ConsumerState<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends ConsumerState<QuestionForm> {
  late String _submitBtnText;
  late String _dialogText;
  final _btnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'questions';
  int? _correctAnsIndex;

  final HtmlEditorController editorController = HtmlEditorController();

  String? _questionType;
  String _optionType = Constants.optionTypes.keys.elementAt(0);

  var questionTitleCtlr = TextEditingController();
  var option1Ctlr = TextEditingController();
  var option2Ctlr = TextEditingController();
  var option3Ctlr = TextEditingController();
  var option4Ctlr = TextEditingController();

  var questionImageCtrl = TextEditingController();
  var questionAudioCtrl = TextEditingController();
  var questionVideoCtrl = TextEditingController();

  String? _selectedCategoryId;

  late Future _quizes;
  String? _selectedQuizId;
  XFile? _selectedQuestionImage;
  Uint8List? _seletedAudioByte;

  XFile? _option1Image;
  XFile? _option2Image;
  XFile? _option3Image;
  XFile? _option4Image;

  var option1ImageCtlr = TextEditingController();
  var option2ImageCtlr = TextEditingController();
  var option3ImageCtlr = TextEditingController();
  var option4ImageCtlr = TextEditingController();

  _onSelectOption1Image() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _option1Image = image;
        option1ImageCtlr.text = image.name;
      });
    }
  }

  _onSelectOption2Image() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _option2Image = image;
        option2ImageCtlr.text = image.name;
      });
    }
  }

  _onSelectOption3Image() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _option3Image = image;
        option3ImageCtlr.text = image.name;
      });
    }
  }

  _onSelectOption4Image() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _option4Image = image;
        option4ImageCtlr.text = image.name;
      });
    }
  }

  Future _onPickImage() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _selectedQuestionImage = image;
        questionImageCtrl.text = image.name;
      });
    }
  }

  Future _onPickAudio() async {
    FilePickerResult? result = await AppService().pickAudio();
    if (result != null) {
      setState(() {
        _seletedAudioByte = result.files.first.bytes;
        questionAudioCtrl.text = result.files.first.name;
      });
    }
  }

  Future<String?> _uploadAudioToFirebaseHosting() async {
    String? audioUrl;
    final Reference storageReference = FirebaseStorage.instance.ref().child('question_audios/${questionAudioCtrl.text}');
    final UploadTask uploadTask = storageReference.putData(_seletedAudioByte!);
    await uploadTask.whenComplete(() async {
      audioUrl = await storageReference.getDownloadURL();
    });
    return audioUrl;
  }

  initData() {
    if (widget.q == null) {
      _questionType = Constants.questionTypes.keys.elementAt(0);
      _quizes = Future.value();
    } else {
      _selectedCategoryId = widget.q?.catId;
      _selectedQuizId = widget.q?.quizId;
      _quizes = FirebaseService().getCategoryBasedQuizes(widget.q!.catId!);
      questionTitleCtlr.text = widget.q!.questionTitle.toString();

      _questionType = widget.q!.questionType;
      _optionType = _getOptionsTyoe();
      if (_getOptionsTyoe() == Constants.optionTypes.keys.elementAt(0)) {
        option1Ctlr.text = widget.q!.options![0];
        option2Ctlr.text = widget.q!.options![1];
        option3Ctlr.text = widget.q!.options![2];
        option4Ctlr.text = widget.q!.options![3];
      }
      if (_getOptionsTyoe() == Constants.optionTypes.keys.elementAt(2)) {
        option1ImageCtlr.text = widget.q!.options![0];
        option2ImageCtlr.text = widget.q!.options![1];
        option3ImageCtlr.text = widget.q!.options![2];
        option4ImageCtlr.text = widget.q!.options![3];
      }

      _correctAnsIndex = widget.q!.correctAnswerIndex!;
      questionImageCtrl.text = widget.q?.questionType == null || widget.q?.questionImageUrl == null ? '' : widget.q!.questionImageUrl.toString();
      _questionType = widget.q!.questionType;
      questionAudioCtrl.text = widget.q!.questionAudioUrl == null ? '' : widget.q!.questionAudioUrl.toString();
      questionVideoCtrl.text = widget.q!.questionVideoUrl == null ? '' : widget.q!.questionVideoUrl.toString();
    }
  }

  String _getOptionsTyoe() {
    if (widget.q!.hasFourOptions == null) {
      return widget.q!.optionsType!;
    } else {
      if (widget.q!.hasFourOptions!) {
        return Constants.optionTypes.keys.elementAt(0);
      } else {
        return Constants.optionTypes.keys.elementAt(1);
      }
    }
  }

  @override
  void initState() {
    _submitBtnText = widget.q == null ? 'Upload Question' : 'Update Question';
    _dialogText = widget.q == null ? 'Uploaded Successfully!' : 'Updated Successfully!';
    initData();
    super.initState();
  }

  _clearForm() {
    questionTitleCtlr.clear();
    option1Ctlr.clear();
    option2Ctlr.clear();
    option3Ctlr.clear();
    option4Ctlr.clear();
    _option1Image = null;
    _option2Image = null;
    _option3Image = null;
    _option4Image = null;
    option1ImageCtlr.clear();
    option2ImageCtlr.clear();
    option3ImageCtlr.clear();
    option4ImageCtlr.clear();
    _correctAnsIndex = null;
    questionImageCtrl.clear();
    questionAudioCtrl.clear();
    questionVideoCtrl.clear();
    editorController.clear();
  }

  void _handleSubmit() async {
    if (hasAccess(ref)) {
      if (_selectedCategoryId != null) {
        if (_selectedQuizId != null) {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            if (_correctAnsIndex != null) {
              _afterValidation();
            } else {
              openCustomDialog(context, 'Select Correct Answer Index', '');
            }
          }
        } else {
          openCustomDialog(context, 'Select A Quiz Name', '');
        }
      } else {
        openCustomDialog(context, 'Select A Category', '');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _afterValidation() {
    if (_questionType == Constants.questionTypes.keys.elementAt(0) || _questionType == Constants.questionTypes.keys.elementAt(3) || _questionType == Constants.questionTypes.keys.elementAt(4)) {
      //text only
      _btnCtlr.start();
      _uploadProcedures();
    } else if (_questionType == Constants.questionTypes.keys.elementAt(1)) {
      _handleImageUpload();
    } else if (_questionType == Constants.questionTypes.keys.elementAt(2)) {
      _handleAudioUpload();
    } else {
      debugPrint('Unexpected error on uploading question');
    }
  }

  _handleImageUpload() async {
    if (_selectedQuestionImage != null) {
      //local Image
      _btnCtlr.start();
      await FirebaseService().uploadImageToFirebaseHosting(_selectedQuestionImage!, 'question_images').then((String? imageUrl) {
        if (imageUrl != null) {
          setState(() => questionImageCtrl.text = imageUrl);
          _uploadProcedures();
        } else {
          setState(() {
            _selectedQuestionImage = null;
            questionImageCtrl.clear();
            _btnCtlr.reset();
          });
        }
      });
    } else {
      //network image
      _btnCtlr.start();
      _uploadProcedures();
    }
  }

  _handleAudioUpload() async {
    if (_seletedAudioByte != null) {
      //local audio
      _btnCtlr.start();
      await _uploadAudioToFirebaseHosting().then((String? audioUrl) {
        if (audioUrl != null) {
          setState(() => questionAudioCtrl.text = audioUrl);
          _uploadProcedures();
        } else {
          setState(() {
            _seletedAudioByte = null;
            questionAudioCtrl.clear();
            _btnCtlr.reset();
          });
        }
      });
    } else {
      //network audio
      _btnCtlr.start();
      _uploadProcedures();
    }
  }

  _uploadProcedures() async {
    await uploadQuestion().then((value) async {
      if (widget.q == null) {
        await await FirebaseService().increaseQuestionCountInQuiz(_selectedQuizId!, null);
        _clearForm();
        ref.invalidate(questionsCountProvider);
      }
      _btnCtlr.reset();
      if(!mounted) return;
      openCustomDialog(context, _dialogText, '');
    });
  }

  Future<List<String>> _getOptions() async {
    List<String> options;
    if (_optionType == Constants.optionTypes.keys.elementAt(0)) {
      options = [option1Ctlr.text, option2Ctlr.text, option3Ctlr.text, option4Ctlr.text];
    } else if (_optionType == Constants.optionTypes.keys.elementAt(1)) {
      options = ['True', 'False'];
    } else if (_optionType == Constants.optionTypes.keys.elementAt(2)) {
      List<String> x = [];
      if (_option1Image != null) {
        String newUpload = await FirebaseService().uploadImageToFirebaseHosting(_option1Image!, 'option_images');
        x.insert(0, newUpload);
      } else {
        x.insert(0, option1ImageCtlr.text);
      }
      if (_option2Image != null) {
        String newUpload = await FirebaseService().uploadImageToFirebaseHosting(_option2Image!, 'option_images');
        x.insert(1, newUpload);
      } else {
        x.insert(1, option2ImageCtlr.text);
      }
      if (_option3Image != null) {
        String newUpload = await FirebaseService().uploadImageToFirebaseHosting(_option3Image!, 'option_images');
        x.insert(2, newUpload);
      } else {
        x.insert(2, option3ImageCtlr.text);
      }
      if (_option4Image != null) {
        String newUpload = await FirebaseService().uploadImageToFirebaseHosting(_option4Image!, 'option_images');
        x.insert(3, newUpload);
      } else {
        x.insert(3, option4ImageCtlr.text);
      }
      options = x;
    } else {
      options = [];
    }
    return options;
  }

  Future uploadQuestion() async {
    List<String>? options = await _getOptions();
    final String docId = widget.q == null ? firestore.collection(collectionName).doc().id : widget.q!.id!;
    final String rawExplaination = await editorController.getText();
    String? explaination = rawExplaination != '' ? rawExplaination : null;
    var createdAt = widget.q == null ? DateTime.now() : widget.q!.createdAt;
    var updatedAt = widget.q == null ? null : DateTime.now();
    Question q = Question(
      id: docId,
      catId: _selectedCategoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      questionTitle: questionTitleCtlr.text,
      quizId: _selectedQuizId,
      options: options,
      correctAnswerIndex: _correctAnsIndex,
      questionType: _questionType,
      questionImageUrl: questionImageCtrl.text.isEmpty ? null : questionImageCtrl.text,
      questionAudioUrl: questionAudioCtrl.text.isEmpty ? null : questionAudioCtrl.text,
      questionVideoUrl: questionVideoCtrl.text.isEmpty ? null : questionVideoCtrl.text,
      explaination: explaination,
      optionsType: _optionType,
    );
    Map<String, dynamic> data = Question.getMap(q);

    await firestore.collection(collectionName).doc(docId).set(data, SetOptions(merge: true));
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
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        CategoryDropdown(
                          selectedCategoryId: _selectedCategoryId,
                          onChanged: (value) {
                            _selectedCategoryId = value;
                            _quizes = FirebaseService().getCategoryBasedQuizes(value);
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Quiz Name',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        FutureBuilder(
                          future: _quizes,
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              final List<Quiz> quizes = snapshot.data ?? [];
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Question Type',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _questionTypeDropdown(),
              const SizedBox(height: 20),
              QuestionTitle(questionType: _questionType),
              const SizedBox(height: 5),
              QuestionTextField(questionType: _questionType, questionTitleCtlr: questionTitleCtlr),
              const SizedBox(height: 20),
              QuestionImage(
                questionType: _questionType,
                questionImageCtrl: questionImageCtrl,
                selectedQuestionImage: _selectedQuestionImage,
                onClear: () {
                  setState(() => _selectedQuestionImage = null);
                },
                onPickImage: _onPickImage,
              ),
              QuestionAudio(
                questionType: _questionType,
                imageCtrl: questionAudioCtrl,
                onClear: () {
                  setState(() => _seletedAudioByte = null);
                },
                onPickAudio: _onPickAudio,
              ),
              QuestionVideo(questionVideoCtrl: questionVideoCtrl, questionType: _questionType),
              _optionTypeWidget(context),
              const SizedBox(height: 20),
              _options(),
              const SizedBox(height: 20),
              _correctAnsDropdown(),
              const SizedBox(height: 30),
              QuestionExplanation(editorController: editorController, q: widget.q),
              const SizedBox(height: 30),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget _options() {
    if (_optionType == Constants.optionTypes.keys.elementAt(0)) {
      return _fourOptions();
    } else if (_optionType == Constants.optionTypes.keys.elementAt(1)) {
      return _twoOptions();
    } else {
      return _imageOptions();
    }
  }

  Wrap _optionTypeWidget(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          LineIcons.list,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(
          width: 5,
        ),
        const Text('Option Type: '),
        const SizedBox(
          width: 30,
        ),
        Radio(
          value: Constants.optionTypes.keys.elementAt(0),
          groupValue: _optionType,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (value) {
            setState(() {
              _optionType = Constants.optionTypes.keys.elementAt(0);
            });
          },
        ),
        Text(Constants.optionTypes.values.elementAt(0)),
        const SizedBox(
          width: 10,
        ),
        Radio(
          value: Constants.optionTypes.keys.elementAt(1),
          groupValue: _optionType,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (value) {
            setState(() {
              _optionType = Constants.optionTypes.keys.elementAt(1);
            });
          },
        ),
        Text(Constants.optionTypes.values.elementAt(1)),
        const SizedBox(
          width: 10,
        ),
        Visibility(
          // Disbale for fill in the blanks question type
          visible: _questionType != Constants.questionTypes.keys.elementAt(4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Radio(
                value: Constants.optionTypes.keys.elementAt(2),
                groupValue: _optionType,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _optionType = Constants.optionTypes.keys.elementAt(2);
                  });
                },
              ),
              Text(Constants.optionTypes.values.elementAt(2)),
            ],
          ),
        ),
      ],
    );
  }

  Column _fourOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: OptionTextField(textController: option1Ctlr, title: 'Option A')),
            const SizedBox(width: 15),
            Expanded(child: OptionTextField(textController: option2Ctlr, title: 'Option B')),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: OptionTextField(textController: option3Ctlr, title: 'Option C')),
            const SizedBox(width: 15),
            Expanded(child: OptionTextField(textController: option4Ctlr, title: 'Option D')),
          ],
        ),
      ],
    );
  }

  Row _twoOptions() {
    return Row(
      children: [
        Expanded(child: OptionTextField(textController: option1Ctlr, title: 'Option A', hintText: 'True', isReadOnly: true, hasValidation: false)),
        const SizedBox(width: 15),
        Expanded(child: OptionTextField(textController: option2Ctlr, title: 'Option B', hintText: 'False', isReadOnly: true, hasValidation: false)),
      ],
    );
  }

  Widget _correctAnsDropdown() {
    bool hasFourOptions = _optionType == Constants.optionTypes.keys.elementAt(0) || _optionType == Constants.optionTypes.keys.elementAt(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            'Correct Answer Index',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
            height: 50,
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
            child: DropdownButtonFormField(
                itemHeight: 50,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (dynamic value) {
                  setState(() {
                    _correctAnsIndex = value;
                  });
                },
                value: _correctAnsIndex,
                hint: const Text('Select Correct Answer'),
                items: <DropdownMenuItem>[
                  const DropdownMenuItem(
                    value: 0,
                    child: Text('Option A'),
                  ),
                  const DropdownMenuItem(
                    value: 1,
                    child: Text('Option B'),
                  ),
                  DropdownMenuItem(
                    enabled: hasFourOptions,
                    value: 2,
                    child: Text(
                      'Option C',
                      style: TextStyle(color: hasFourOptions ? Colors.grey[900] : Colors.grey[200]),
                    ),
                  ),
                  DropdownMenuItem(
                    enabled: hasFourOptions,
                    value: 3,
                    child: Text(
                      'Option D',
                      style: TextStyle(color: hasFourOptions ? Colors.grey[900] : Colors.grey[200]),
                    ),
                  )
                ])),
      ],
    );
  }

  Widget _questionTypeDropdown() {
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
          itemHeight: 50,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (dynamic value) {
            debugPrint(value);
            setState(() {
              _questionType = value;
            });
          },
          value: _questionType,
          hint: const Text('Select Category'),
          items: Constants.questionTypes
              .map((key, value) {
                return MapEntry(
                    value,
                    DropdownMenuItem(
                      value: key,
                      child: Text(value),
                    ));
              })
              .values
              .toList(),
        ));
  }

  Column _imageOptions() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _optionImageBox(option1ImageCtlr, _option1Image, _onSelectOption1Image, 0, 'Option A'),
            const SizedBox(
              width: 15,
            ),
            _optionImageBox(option2ImageCtlr, _option2Image, _onSelectOption2Image, 1, 'Option B'),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _optionImageBox(option3ImageCtlr, _option3Image, _onSelectOption3Image, 2, 'Option C'),
            const SizedBox(
              width: 15,
            ),
            _optionImageBox(option4ImageCtlr, _option4Image, _onSelectOption4Image, 3, 'Option D'),
          ],
        ),
      ],
    );
  }

  Expanded _optionImageBox(TextEditingController textCtlr, XFile? image, VoidCallback onPickImage, int itemIndex, String optionName) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              optionName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ImageTextField(
            imageCtrl: textCtlr,
            imageFile: image,
            onClear: () {
              setState(() {
                if (itemIndex == 0) {
                  _option1Image = null;
                } else if (itemIndex == 1) {
                  _option2Image = null;
                } else if (itemIndex == 2) {
                  _option3Image = null;
                } else {
                  _option4Image = null;
                }
              });
            },
            onPickImage: onPickImage,
          ),
        ],
      ),
    );
  }
}
