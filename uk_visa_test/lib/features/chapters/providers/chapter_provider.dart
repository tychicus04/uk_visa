import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/repositories/chapter_repository.dart';

final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final chapterRepository = ref.watch(chapterRepositoryProvider);
  return chapterRepository.getAllChapters();
});

final chapterDetailProvider = FutureProvider.family<Chapter, int>((ref, chapterId) async {
  final chapterRepository = ref.watch(chapterRepositoryProvider);
  return chapterRepository.getChapter(chapterId);
});
