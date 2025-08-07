import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chapter_service.dart';
import '../models/chapter_model.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  final chapterService = ref.watch(chapterServiceProvider);
  return ChapterRepository(chapterService);
});

class ChapterRepository {
  final ChapterService _chapterService;

  ChapterRepository(this._chapterService);

  /// Get all chapters
  Future<List<Chapter>> getAllChapters() async {
    final response = await _chapterService.getAllChapters();

    if (response.success && response.data != null) {
      return (response.data! as List).map((e) => Chapter.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load chapters');
    }
  }

  /// Get specific chapter with tests
  Future<Chapter> getChapter(int chapterId) async {
    final response = await _chapterService.getChapter(chapterId);

    if (response.success && response.data != null) {
      return Chapter.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to load chapter');
    }
  }
}