// lib/features/chapters/providers/chapter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chapter_model.dart';

final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1));

  return [
    Chapter(
      id: 1,
      chapterNumber: 1,
      name: 'The Values and Principles of the UK',
      description: 'Learn about the fundamental values that underpin British society.',
      totalTests: 5,
      freeTests: 2,
      premiumTests: 3,
      createdAt: DateTime.now().toIso8601String(),
    ),
    Chapter(
      id: 2,
      chapterNumber: 2,
      name: 'What is the UK?',
      description: 'Understand the geography, history, and structure of the United Kingdom.',
      totalTests: 4,
      freeTests: 1,
      premiumTests: 3,
      createdAt: DateTime.now().toIso8601String(),
    ),
    Chapter(
      id: 3,
      chapterNumber: 3,
      name: 'A Long and Illustrious History',
      description: 'Explore the rich history of Britain from ancient times to the present.',
      totalTests: 6,
      freeTests: 2,
      premiumTests: 4,
      createdAt: DateTime.now().toIso8601String(),
    ),
    Chapter(
      id: 4,
      chapterNumber: 4,
      name: 'A Modern, Thriving Society',
      description: 'Discover contemporary British culture, arts, and society.',
      totalTests: 5,
      freeTests: 1,
      premiumTests: 4,
      createdAt: DateTime.now().toIso8601String(),
    ),
    Chapter(
      id: 5,
      chapterNumber: 5,
      name: 'The UK Government, the Law and Your Role',
      description: 'Learn about the UK government system, laws, and citizen responsibilities.',
      totalTests: 4,
      freeTests: 1,
      premiumTests: 3,
      createdAt: DateTime.now().toIso8601String(),
    ),
  ];
});

final chapterDetailProvider = FutureProvider.family<Chapter, int>((ref, chapterId) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(milliseconds: 500));

  return Chapter(
    id: chapterId,
    chapterNumber: chapterId,
    name: 'Chapter $chapterId: The Values and Principles of the UK',
    description: 'Learn about the fundamental values that underpin British society and the responsibilities of citizenship.',
    totalTests: 5,
    freeTests: 2,
    premiumTests: 3,
    createdAt: DateTime.now().toIso8601String(),
    tests: [], // This would be populated with actual test data
  );
});
