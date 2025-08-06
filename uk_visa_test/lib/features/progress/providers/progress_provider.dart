// lib/features/progress/providers/progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1));

  return {
    'practiceProgress': 76,
    'readingProgress': 89,
    'dailyQuestionsAnswered': 29,
    'testsCompleted': 34,
    'totalTests': 45,
    'sectionsRead': 24,
    'totalSections': 27,
    'scores': {
      'lastTest': 90,
      'last5Tests': 87,
      'last10Tests': 79,
      'last20Tests': 65,
      'allTests': 63,
      'totalAttempts': 23,
    },
  };
});

