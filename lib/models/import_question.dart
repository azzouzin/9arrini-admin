class ImportQuestion {
  final String question;
  final List options;
  final int correctAnswerIndex;
  final String questionType;
  final String optionType;
  String? explanation;
  String? questionImageURL;
  String? questionAudioURL;
  String? questionVideoURL;

  ImportQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.questionType,
    required this.optionType,
    this.explanation,
    this.questionImageURL,
    this.questionAudioURL,
    this.questionVideoURL,
  });
}
