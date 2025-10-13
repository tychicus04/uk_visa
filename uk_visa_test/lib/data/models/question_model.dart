// lib/data/models/question_model.dart - ENHANCED
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'answer_model.dart';

part 'question_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Question extends Equatable {
  const Question({
    required this.id,
    required this.testId,
    required this.questionId,
    required this.questionText,
    this.questionTextVi,
    this.questionTextPl,      // 🆕 Polish
    this.questionTextPa,      // 🆕 Punjabi
    this.questionTextUr,      // 🆕 Urdu
    this.questionTextRo,      // 🆕 Romanian
    this.questionTextEs,      // 🆕 Spanish
    this.questionTextPt,      // 🆕 Portuguese
    this.questionTextAr,      // 🆕 Arabic
    this.questionTextZh,      // 🆕 Chinese
    this.questionTextFr,      // 🆕 French
    this.questionTextIt,      // 🆕 Italian
    this.questionTextRu,      // 🆕 Russian
    this.questionTextTr,      // 🆕 Turkish
    this.questionTextTa,      // 🆕 Tamil
    this.questionTextSo,      // 🆕 Somali
    required this.questionType,
    this.requiredAnswers = 1, // 🆕 Number of required answers for this question
    this.explanation,
    this.explanationVi,
    this.explanationPl,       // 🆕 Polish
    this.explanationPa,       // 🆕 Punjabi
    this.explanationUr,       // 🆕 Urdu
    this.explanationRo,       // 🆕 Romanian
    this.explanationEs,       // 🆕 Spanish
    this.explanationPt,       // 🆕 Portuguese
    this.explanationAr,       // 🆕 Arabic
    this.explanationZh,       // 🆕 Chinese
    this.explanationFr,       // 🆕 French
    this.explanationIt,       // 🆕 Italian
    this.explanationRu,       // 🆕 Russian
    this.explanationTr,       // 🆕 Turkish
    this.explanationTa,       // 🆕 Tamil
    this.explanationSo,       // 🆕 Somali
    required this.answers,
    required this.createdAt,
  });

  final String id;
  final String testId;
  final String questionId;
  final String questionText;

  // 🆕 Multi-language question text
  final String? questionTextVi;
  final String? questionTextPl;
  final String? questionTextPa;
  final String? questionTextUr;
  final String? questionTextRo;
  final String? questionTextEs;
  final String? questionTextPt;
  final String? questionTextAr;
  final String? questionTextZh;      // 🆕 Chinese
  final String? questionTextFr;      // 🆕 French
  final String? questionTextIt;      // 🆕 Italian
  final String? questionTextRu;      // 🆕 Russian
  final String? questionTextTr;      // 🆕 Turkish
  final String? questionTextTa;      // 🆕 Tamil
  final String? questionTextSo;      // 🆕 Somali

  final String questionType;
  final int requiredAnswers; // 🆕 Number of required answers for this question
  final String? explanation;

  // 🆕 Multi-language explanations
  final String? explanationVi;
  final String? explanationPl;
  final String? explanationPa;
  final String? explanationUr;
  final String? explanationRo;
  final String? explanationEs;
  final String? explanationPt;
  final String? explanationAr;
  final String? explanationZh;       // 🆕 Chinese
  final String? explanationFr;       // 🆕 French
  final String? explanationIt;       // 🆕 Italian
  final String? explanationRu;       // 🆕 Russian
  final String? explanationTr;       // 🆕 Turkish
  final String? explanationTa;       // 🆕 Tamil
  final String? explanationSo;       // 🆕 Somali

  final List<Answer> answers;
  final String createdAt;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '0',
      testId: json['test_id']?.toString() ?? '0',
      questionId: json['question_id']?.toString() ?? '',
      questionText: json['question_text']?.toString() ?? '',
      questionTextVi: json['question_text_vi']?.toString(),
      questionTextPl: json['question_text_pl']?.toString(),
      questionTextPa: json['question_text_pa']?.toString(),
      questionTextUr: json['question_text_ur']?.toString(),
      questionTextRo: json['question_text_ro']?.toString(),
      questionTextEs: json['question_text_es']?.toString(),
      questionTextPt: json['question_text_pt']?.toString(),
      questionTextAr: json['question_text_ar']?.toString(),
      questionTextZh: json['question_text_zh']?.toString(),  // 🆕 Chinese
      questionTextFr: json['question_text_fr']?.toString(),  // 🆕 French
      questionTextIt: json['question_text_it']?.toString(),  // 🆕 Italian
      questionTextRu: json['question_text_ru']?.toString(),  // 🆕 Russian
      questionTextTr: json['question_text_tr']?.toString(),  // 🆕 Turkish
      questionTextTa: json['question_text_ta']?.toString(),  // 🆕 Tamil
      questionTextSo: json['question_text_so']?.toString(),  // 🆕 Somali
      questionType: json['question_type']?.toString() ?? 'radio',
      requiredAnswers: json['required_answers'] != null 
          ? int.tryParse(json['required_answers'].toString()) ?? 1 
          : 1, // Default to 1 if not specified
      explanation: json['explanation']?.toString(),
      explanationVi: json['explanation_vi']?.toString(),
      explanationPl: json['explanation_pl']?.toString(),
      explanationPa: json['explanation_pa']?.toString(),
      explanationUr: json['explanation_ur']?.toString(),
      explanationRo: json['explanation_ro']?.toString(),
      explanationEs: json['explanation_es']?.toString(),
      explanationPt: json['explanation_pt']?.toString(),
      explanationAr: json['explanation_ar']?.toString(),
      explanationZh: json['explanation_zh']?.toString(),    // 🆕 Chinese
      explanationFr: json['explanation_fr']?.toString(),    // 🆕 French
      explanationIt: json['explanation_it']?.toString(),    // 🆕 Italian
      explanationRu: json['explanation_ru']?.toString(),    // 🆕 Russian
      explanationTr: json['explanation_tr']?.toString(),    // 🆕 Turkish
      explanationTa: json['explanation_ta']?.toString(),    // 🆕 Tamil
      explanationSo: json['explanation_so']?.toString(),    // 🆕 Somali
      answers: json['answers'] != null
          ? (json['answers'] as List).map((e) => Answer.fromJson(e)).toList()
          : <Answer>[],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  // 🆕 ENHANCED: Dynamic language support
  String getQuestionText({String? languageCode}) {
    if (languageCode == null || languageCode == 'en') {
      return questionText;
    }

    switch (languageCode) {
      case 'vi': return questionTextVi?.isNotEmpty == true ? questionTextVi! : questionText;
      case 'pl': return questionTextPl?.isNotEmpty == true ? questionTextPl! : questionText;
      case 'pa': return questionTextPa?.isNotEmpty == true ? questionTextPa! : questionText;
      case 'ur': return questionTextUr?.isNotEmpty == true ? questionTextUr! : questionText;
      case 'ro': return questionTextRo?.isNotEmpty == true ? questionTextRo! : questionText;
      case 'es': return questionTextEs?.isNotEmpty == true ? questionTextEs! : questionText;
      case 'pt': return questionTextPt?.isNotEmpty == true ? questionTextPt! : questionText;
      case 'ar': return questionTextAr?.isNotEmpty == true ? questionTextAr! : questionText;
      case 'zh': return questionTextZh?.isNotEmpty == true ? questionTextZh! : questionText;
      case 'fr': return questionTextFr?.isNotEmpty == true ? questionTextFr! : questionText;
      case 'it': return questionTextIt?.isNotEmpty == true ? questionTextIt! : questionText;
      case 'ru': return questionTextRu?.isNotEmpty == true ? questionTextRu! : questionText;
      case 'tr': return questionTextTr?.isNotEmpty == true ? questionTextTr! : questionText;
      case 'ta': return questionTextTa?.isNotEmpty == true ? questionTextTa! : questionText;
      case 'so': return questionTextSo?.isNotEmpty == true ? questionTextSo! : questionText;
      default: return questionText;
    }
  }

  String getExplanation({String? languageCode}) {
    if (languageCode == null || languageCode == 'en') {
      return explanation ?? '';
    }

    switch (languageCode) {
      case 'vi': return explanationVi?.isNotEmpty == true ? explanationVi! : (explanation ?? '');
      case 'pl': return explanationPl?.isNotEmpty == true ? explanationPl! : (explanation ?? '');
      case 'pa': return explanationPa?.isNotEmpty == true ? explanationPa! : (explanation ?? '');
      case 'ur': return explanationUr?.isNotEmpty == true ? explanationUr! : (explanation ?? '');
      case 'ro': return explanationRo?.isNotEmpty == true ? explanationRo! : (explanation ?? '');
      case 'es': return explanationEs?.isNotEmpty == true ? explanationEs! : (explanation ?? '');
      case 'pt': return explanationPt?.isNotEmpty == true ? explanationPt! : (explanation ?? '');
      case 'ar': return explanationAr?.isNotEmpty == true ? explanationAr! : (explanation ?? '');
      case 'zh': return explanationZh?.isNotEmpty == true ? explanationZh! : (explanation ?? '');
      case 'fr': return explanationFr?.isNotEmpty == true ? explanationFr! : (explanation ?? '');
      case 'it': return explanationIt?.isNotEmpty == true ? explanationIt! : (explanation ?? '');
      case 'ru': return explanationRu?.isNotEmpty == true ? explanationRu! : (explanation ?? '');
      case 'tr': return explanationTr?.isNotEmpty == true ? explanationTr! : (explanation ?? '');
      case 'ta': return explanationTa?.isNotEmpty == true ? explanationTa! : (explanation ?? '');
      case 'so': return explanationSo?.isNotEmpty == true ? explanationSo! : (explanation ?? '');
      default: return explanation ?? '';
    }
  }

  // 🆕 NEW: Check translation availability
  bool hasTranslation(String languageCode) {
    switch (languageCode) {
      case 'en': return true;
      case 'vi': return questionTextVi?.isNotEmpty == true;
      case 'pl': return questionTextPl?.isNotEmpty == true;
      case 'pa': return questionTextPa?.isNotEmpty == true;
      case 'ur': return questionTextUr?.isNotEmpty == true;
      case 'ro': return questionTextRo?.isNotEmpty == true;
      case 'es': return questionTextEs?.isNotEmpty == true;
      case 'pt': return questionTextPt?.isNotEmpty == true;
      case 'ar': return questionTextAr?.isNotEmpty == true;
      case 'zh': return questionTextZh?.isNotEmpty == true;
      case 'fr': return questionTextFr?.isNotEmpty == true;
      case 'it': return questionTextIt?.isNotEmpty == true;
      case 'ru': return questionTextRu?.isNotEmpty == true;
      case 'tr': return questionTextTr?.isNotEmpty == true;
      case 'ta': return questionTextTa?.isNotEmpty == true;
      case 'so': return questionTextSo?.isNotEmpty == true;
      default: return false;
    }
  }

  bool hasExplanationTranslation(String languageCode) {
    switch (languageCode) {
      case 'en': return explanation?.isNotEmpty == true;
      case 'vi': return explanationVi?.isNotEmpty == true;
      case 'pl': return explanationPl?.isNotEmpty == true;
      case 'pa': return explanationPa?.isNotEmpty == true;
      case 'ur': return explanationUr?.isNotEmpty == true;
      case 'ro': return explanationRo?.isNotEmpty == true;
      case 'es': return explanationEs?.isNotEmpty == true;
      case 'pt': return explanationPt?.isNotEmpty == true;
      case 'ar': return explanationAr?.isNotEmpty == true;
      case 'zh': return explanationZh?.isNotEmpty == true;
      case 'fr': return explanationFr?.isNotEmpty == true;
      case 'it': return explanationIt?.isNotEmpty == true;
      case 'ru': return explanationRu?.isNotEmpty == true;
      case 'tr': return explanationTr?.isNotEmpty == true;
      case 'ta': return explanationTa?.isNotEmpty == true;
      case 'so': return explanationSo?.isNotEmpty == true;
      default: return false;
    }
  }

  // 🔄 UPDATED: Deprecated methods for backward compatibility
  @deprecated
  String getQuestionText_Old({bool isVietnamese = false}) {
    return getQuestionText(languageCode: isVietnamese ? 'vi' : 'en');
  }

  @deprecated
  String getExplanation_Old({bool isVietnamese = false}) {
    return getExplanation(languageCode: isVietnamese ? 'vi' : 'en');
  }

  @deprecated
  bool get hasVietnameseTranslation => hasTranslation('vi');

  @deprecated
  bool get hasVietnameseExplanation => hasExplanationTranslation('vi');

  // ... rest of existing code ...

  @override
  List<Object?> get props => [
    id, testId, questionId, questionText,
    questionTextVi, questionTextPl, questionTextPa, questionTextUr,
    questionTextRo, questionTextEs, questionTextPt, questionTextAr,
    questionType, requiredAnswers, explanation,
    explanationVi, explanationPl, explanationPa, explanationUr,
    explanationRo, explanationEs, explanationPt, explanationAr,
    answers, createdAt,
  ];
}