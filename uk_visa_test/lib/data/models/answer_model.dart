// lib/data/models/answer_model.dart - ENHANCED
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Answer extends Equatable {
  const Answer({
    required this.id,
    required this.questionId,
    required this.answerId,
    required this.answerText,
    this.answerTextVi,
    this.answerTextPl, // 🆕 Polish
    this.answerTextPa, // 🆕 Punjabi
    this.answerTextUr, // 🆕 Urdu
    this.answerTextRo, // 🆕 Romanian
    this.answerTextEs, // 🆕 Spanish
    this.answerTextPt, // 🆕 Portuguese
    this.answerTextAr, // 🆕 Arabic
    this.answerTextZh, // 🆕 Chinese
    this.answerTextFr, // 🆕 French
    this.answerTextIt, // 🆕 Italian
    this.answerTextRu, // 🆕 Russian
    this.answerTextTr, // 🆕 Turkish
    this.answerTextTa, // 🆕 Tamil
    this.answerTextSo, // 🆕 Somali
    this.answerTextUk, // 🆕 Ukrainian
    this.answerTextSq, // 🆕 Albanian
    this.answerTextBn, // 🆕 Bengali
    this.answerTextMl, // 🆕 Malayalam
    this.answerTextTe, // 🆕 Telugu
    this.answerTextAm, // 🆕 Amharic
    this.answerTextYo, // 🆕 Yoruba
    this.answerTextSw, // 🆕 Swahili
    this.answerTextKu, // 🆕 Kurdish
    this.answerTextFa, // 🆕 Persian
    this.answerTextPs, // 🆕 Pashto
    this.isCorrect,
    this.wasSelected,
    this.createdAt,
  });

  final String id;
  final String questionId;
  final String answerId;
  final String answerText;

  // 🆕 Multi-language fields
  final String? answerTextVi;
  final String? answerTextPl;
  final String? answerTextPa;
  final String? answerTextUr;
  final String? answerTextRo;
  final String? answerTextEs;
  final String? answerTextPt;
  final String? answerTextAr;
  final String? answerTextZh; // 🆕 Chinese
  final String? answerTextFr; // 🆕 French
  final String? answerTextIt; // 🆕 Italian
  final String? answerTextRu; // 🆕 Russian
  final String? answerTextTr; // 🆕 Turkish
  final String? answerTextTa; // 🆕 Tamil
  final String? answerTextSo; // 🆕 Somali
  final String? answerTextUk; // 🆕 Ukrainian
  final String? answerTextSq; // 🆕 Albanian
  final String? answerTextBn; // 🆕 Bengali
  final String? answerTextMl; // 🆕 Malayalam
  final String? answerTextTe; // 🆕 Telugu
  final String? answerTextAm; // 🆕 Amharic
  final String? answerTextYo; // 🆕 Yoruba
  final String? answerTextSw; // 🆕 Swahili
  final String? answerTextKu; // 🆕 Kurdish
  final String? answerTextFa; // 🆕 Persian
  final String? answerTextPs; // 🆕 Pashto

  final bool? isCorrect;
  final bool? wasSelected;
  final String? createdAt;

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: json['id']?.toString() ?? '0',
        questionId: json['question_id']?.toString() ?? '0',
        answerId: json['answer_id']?.toString() ?? '',
        answerText: json['answer_text']?.toString() ?? '',
        answerTextVi: json['answer_text_vi']?.toString(),
        answerTextPl: json['answer_text_pl']?.toString(),
        answerTextPa: json['answer_text_pa']?.toString(),
        answerTextUr: json['answer_text_ur']?.toString(),
        answerTextRo: json['answer_text_ro']?.toString(),
        answerTextEs: json['answer_text_es']?.toString(),
        answerTextPt: json['answer_text_pt']?.toString(),
        answerTextAr: json['answer_text_ar']?.toString(),
        answerTextZh: json['answer_text_zh']?.toString(), // 🆕 Chinese
        answerTextFr: json['answer_text_fr']?.toString(), // 🆕 French
        answerTextIt: json['answer_text_it']?.toString(), // 🆕 Italian
        answerTextRu: json['answer_text_ru']?.toString(), // 🆕 Russian
        answerTextTr: json['answer_text_tr']?.toString(), // 🆕 Turkish
        answerTextTa: json['answer_text_ta']?.toString(), // 🆕 Tamil
        answerTextSo: json['answer_text_so']?.toString(), // 🆕 Somali
        answerTextUk: json['answer_text_uk']?.toString(), // 🆕 Ukrainian
        answerTextSq: json['answer_text_sq']?.toString(), // 🆕 Albanian
        answerTextBn: json['answer_text_bn']?.toString(), // 🆕 Bengali
        answerTextMl: json['answer_text_ml']?.toString(), // 🆕 Malayalam
        answerTextTe: json['answer_text_te']?.toString(), // 🆕 Telugu
        answerTextAm: json['answer_text_am']?.toString(), // 🆕 Amharic
        answerTextYo: json['answer_text_yo']?.toString(), // 🆕 Yoruba
        answerTextSw: json['answer_text_sw']?.toString(), // 🆕 Swahili
        answerTextKu: json['answer_text_ku']?.toString(), // 🆕 Kurdish
        answerTextFa: json['answer_text_fa']?.toString(), // 🆕 Persian
        answerTextPs: json['answer_text_ps']?.toString(), // 🆕 Pashto
        isCorrect: _parseBool(json['is_correct']),
        wasSelected: _parseBool(json['was_selected']),
        createdAt: json['created_at']?.toString(),
      );

  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  static bool? _parseBool(value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }

  // 🆕 ENHANCED: Dynamic language support
  String getAnswerText({String? languageCode}) {
    if (languageCode == null || languageCode == 'en') {
      return answerText;
    }

    switch (languageCode) {
      case 'vi':
        return answerTextVi?.isNotEmpty == true ? answerTextVi! : answerText;
      case 'pl':
        return answerTextPl?.isNotEmpty == true ? answerTextPl! : answerText;
      case 'pa':
        return answerTextPa?.isNotEmpty == true ? answerTextPa! : answerText;
      case 'ur':
        return answerTextUr?.isNotEmpty == true ? answerTextUr! : answerText;
      case 'ro':
        return answerTextRo?.isNotEmpty == true ? answerTextRo! : answerText;
      case 'es':
        return answerTextEs?.isNotEmpty == true ? answerTextEs! : answerText;
      case 'pt':
        return answerTextPt?.isNotEmpty == true ? answerTextPt! : answerText;
      case 'ar':
        return answerTextAr?.isNotEmpty == true ? answerTextAr! : answerText;
      case 'zh':
        return answerTextZh?.isNotEmpty == true ? answerTextZh! : answerText;
      case 'fr':
        return answerTextFr?.isNotEmpty == true ? answerTextFr! : answerText;
      case 'it':
        return answerTextIt?.isNotEmpty == true ? answerTextIt! : answerText;
      case 'ru':
        return answerTextRu?.isNotEmpty == true ? answerTextRu! : answerText;
      case 'tr':
        return answerTextTr?.isNotEmpty == true ? answerTextTr! : answerText;
      case 'ta':
        return answerTextTa?.isNotEmpty == true ? answerTextTa! : answerText;
      case 'so':
        return answerTextSo?.isNotEmpty == true ? answerTextSo! : answerText;
      case 'uk':
        return answerTextUk?.isNotEmpty == true ? answerTextUk! : answerText;
      case 'sq':
        return answerTextSq?.isNotEmpty == true ? answerTextSq! : answerText;
      case 'bn':
        return answerTextBn?.isNotEmpty == true ? answerTextBn! : answerText;
      case 'ml':
        return answerTextMl?.isNotEmpty == true ? answerTextMl! : answerText;
      case 'te':
        return answerTextTe?.isNotEmpty == true ? answerTextTe! : answerText;
      case 'am':
        return answerTextAm?.isNotEmpty == true ? answerTextAm! : answerText;
      case 'yo':
        return answerTextYo?.isNotEmpty == true ? answerTextYo! : answerText;
      case 'sw':
        return answerTextSw?.isNotEmpty == true ? answerTextSw! : answerText;
      case 'ku':
        return answerTextKu?.isNotEmpty == true ? answerTextKu! : answerText;
      case 'fa':
        return answerTextFa?.isNotEmpty == true ? answerTextFa! : answerText;
      case 'ps':
        return answerTextPs?.isNotEmpty == true ? answerTextPs! : answerText;
      default:
        return answerText;
    }
  }

  // 🆕 NEW: Check if translation exists for language
  bool hasTranslation(String languageCode) {
    switch (languageCode) {
      case 'en':
        return true; // Always have English
      case 'vi':
        return answerTextVi?.isNotEmpty == true;
      case 'pl':
        return answerTextPl?.isNotEmpty == true;
      case 'pa':
        return answerTextPa?.isNotEmpty == true;
      case 'ur':
        return answerTextUr?.isNotEmpty == true;
      case 'ro':
        return answerTextRo?.isNotEmpty == true;
      case 'es':
        return answerTextEs?.isNotEmpty == true;
      case 'pt':
        return answerTextPt?.isNotEmpty == true;
      case 'ar':
        return answerTextAr?.isNotEmpty == true;
      case 'zh':
        return answerTextZh?.isNotEmpty == true;
      case 'fr':
        return answerTextFr?.isNotEmpty == true;
      case 'it':
        return answerTextIt?.isNotEmpty == true;
      case 'ru':
        return answerTextRu?.isNotEmpty == true;
      case 'tr':
        return answerTextTr?.isNotEmpty == true;
      case 'ta':
        return answerTextTa?.isNotEmpty == true;
      case 'so':
        return answerTextSo?.isNotEmpty == true;
      case 'uk':
        return answerTextUk?.isNotEmpty == true;
      case 'sq':
        return answerTextSq?.isNotEmpty == true;
      case 'bn':
        return answerTextBn?.isNotEmpty == true;
      case 'ml':
        return answerTextMl?.isNotEmpty == true;
      case 'te':
        return answerTextTe?.isNotEmpty == true;
      case 'am':
        return answerTextAm?.isNotEmpty == true;
      case 'yo':
        return answerTextYo?.isNotEmpty == true;
      case 'sw':
        return answerTextSw?.isNotEmpty == true;
      case 'ku':
        return answerTextKu?.isNotEmpty == true;
      case 'fa':
        return answerTextFa?.isNotEmpty == true;
      case 'ps':
        return answerTextPs?.isNotEmpty == true;
      default:
        return false;
    }
  }

  // 🔄 UPDATED: Deprecated method for backward compatibility
  @deprecated
  String getAnswerText_Old({bool useVietnamese = false}) {
    return getAnswerText(languageCode: useVietnamese ? 'vi' : 'en');
  }

  @deprecated
  bool get hasVietnameseTranslation => hasTranslation('vi');

  // ... rest of existing code ...

  @override
  List<Object?> get props => [
        id,
        questionId,
        answerId,
        answerText,
        answerTextVi,
        answerTextPl,
        answerTextPa,
        answerTextUr,
        answerTextRo,
        answerTextEs,
        answerTextPt,
        answerTextAr,
        answerTextZh,
        answerTextFr,
        answerTextIt,
        answerTextRu,
        answerTextTr,
        answerTextTa,
        answerTextSo,
        answerTextUk,
        answerTextSq,
        answerTextBn,
        answerTextMl,
        answerTextTe,
        answerTextAm,
        answerTextYo,
        answerTextSw,
        answerTextKu,
        answerTextFa,
        answerTextPs,
        isCorrect,
        wasSelected,
        createdAt,
      ];
}
