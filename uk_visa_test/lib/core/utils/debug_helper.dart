// lib/core/utils/debug_helper.dart
import 'dart:convert';

class DebugHelper {

  /// Debug print API response structure
  static void debugApiResponse(String endpoint, Map<String, dynamic> response, {int maxDepth = 3}) {
    print('🔍 === DEBUG API RESPONSE ===');
    print('📍 Endpoint: $endpoint');
    print('📊 Response structure:');
    _printObjectStructure(response, '', 0, maxDepth);
    print('🔍 === END DEBUG ===');
  }

  /// Debug print object structure recursively
  static void _printObjectStructure(dynamic obj, String prefix, int depth, int maxDepth) {
    if (depth > maxDepth) {
      print('${prefix}... (max depth reached)');
      return;
    }

    if (obj == null) {
      print('${prefix}null');
    } else if (obj is Map) {
      print('${prefix}Map (${obj.length} keys):');
      obj.forEach((key, value) {
        final newPrefix = '${prefix}  $key: ';
        if (value is Map || value is List) {
          print(newPrefix);
          _printObjectStructure(value, prefix + '    ', depth + 1, maxDepth);
        } else {
          final valueStr = value.toString();
          final displayValue = valueStr.length > 50 ? '${valueStr.substring(0, 50)}...' : valueStr;
          print('$newPrefix$displayValue (${value.runtimeType})');
        }
      });
    } else if (obj is List) {
      print('${prefix}List (${obj.length} items):');
      if (obj.isNotEmpty) {
        print('${prefix}  [0]: ');
        _printObjectStructure(obj[0], prefix + '    ', depth + 1, maxDepth);
        if (obj.length > 1) {
          print('${prefix}  ... and ${obj.length - 1} more items');
        }
      }
    } else {
      final valueStr = obj.toString();
      final displayValue = valueStr.length > 100 ? '${valueStr.substring(0, 100)}...' : valueStr;
      print('${prefix}$displayValue (${obj.runtimeType})');
    }
  }

  /// Debug print test object
  static void debugTestObject(dynamic test) {
    print('🎯 === DEBUG TEST OBJECT ===');
    if (test == null) {
      print('❌ Test is null');
      return;
    }

    try {
      print('📋 Test basic info:');
      print('   ID: ${test.id}');
      print('   Title: ${test.displayTitle}');
      print('   Type: ${test.testType}');
      print('   Questions: ${test.questions?.length ?? 'null'}');

      if (test.questions != null && test.questions.isNotEmpty) {
        print('📝 First question:');
        final firstQ = test.questions[0];
        print('   Q ID: ${firstQ.id}');
        print('   Q Text: ${firstQ.questionText.substring(0, 50)}...');
        print('   Q Type: ${firstQ.questionType}');
        print('   Answers: ${firstQ.answers.length}');

        if (firstQ.answers.isNotEmpty) {
          print('   First answer: ${firstQ.answers[0].answerText.substring(0, 30)}...');
        }
      }
    } catch (e) {
      print('❌ Error debugging test object: $e');
    }
    print('🎯 === END DEBUG ===');
  }

  /// Debug print Question object
  static void debugQuestionObject(dynamic question) {
    print('❓ === DEBUG QUESTION ===');
    if (question == null) {
      print('❌ Question is null');
      return;
    }

    try {
      print('📝 Question info:');
      print('   ID: ${question.id}');
      print('   Question ID: ${question.questionId}');
      print('   Text: ${question.questionText}');
      print('   Type: ${question.questionType}');
      print('   Vietnamese: ${question.questionTextVi ?? 'N/A'}');
      print('   Answers count: ${question.answers?.length ?? 0}');

      if (question.answers != null) {
        for (int i = 0; i < question.answers.length; i++) {
          final answer = question.answers[i];
          print('   Answer $i: ${answer.answerId} - ${answer.answerText}');
        }
      }
    } catch (e) {
      print('❌ Error debugging question: $e');
    }
    print('❓ === END DEBUG ===');
  }

  /// Check if response is truncated
  static bool isResponseTruncated(String responseText) {
    // Check if response ends abruptly without proper JSON closing
    final trimmed = responseText.trim();
    if (!trimmed.endsWith('}') && !trimmed.endsWith(']')) {
      print('⚠️ WARNING: Response appears to be truncated!');
      print('📏 Response length: ${responseText.length}');
      print('📄 Last 100 characters: ${responseText.substring(responseText.length - 100)}');
      return true;
    }
    return false;
  }

  /// Try to fix truncated JSON
  static String? tryFixTruncatedJson(String responseText) {
    if (!isResponseTruncated(responseText)) {
      return responseText;
    }

    print('🔧 Attempting to fix truncated JSON...');

    // Count opening vs closing braces/brackets
    int openBraces = 0;
    int closeBraces = 0;
    int openBrackets = 0;
    int closeBrackets = 0;

    for (int i = 0; i < responseText.length; i++) {
      switch (responseText[i]) {
        case '{':
          openBraces++;
          break;
        case '}':
          closeBraces++;
          break;
        case '[':
          openBrackets++;
          break;
        case ']':
          closeBrackets++;
          break;
      }
    }

    // Add missing closing braces/brackets
    String fixed = responseText;

    // Add missing closing brackets first
    for (int i = 0; i < (openBrackets - closeBrackets); i++) {
      fixed += ']';
    }

    // Add missing closing braces
    for (int i = 0; i < (openBraces - closeBraces); i++) {
      fixed += '}';
    }

    print('🔧 Fixed JSON length: ${fixed.length} (added ${fixed.length - responseText.length} characters)');

    // Test if it's valid JSON now
    try {
      final decoded = jsonDecode(fixed);
      print('✅ Successfully fixed truncated JSON');
      return fixed;
    } catch (e) {
      print('❌ Could not fix truncated JSON: $e');
      return null;
    }
  }
}

// Extension to make debugging easier
extension DebugExtensions on dynamic {
  void debugPrint([String? label]) {
    if (label != null) {
      print('🔍 DEBUG $label:');
    }
    DebugHelper._printObjectStructure(this, '', 0, 3);
  }
}