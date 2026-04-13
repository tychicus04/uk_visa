import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_chapter_service.dart';
import '../models/chapter_model.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  final chapterService = ref.watch(offlineChapterServiceProvider);
  return ChapterRepository(chapterService);
});

class ChapterRepository {
  final OfflineChapterService _chapterService;

  ChapterRepository(this._chapterService);

  /// Get all chapters (offline mode)
  Future<List<Chapter>> getAllChapters() async {
    final response = await _chapterService.getAllChapters();

    if (response.success && response.data != null) {
      return (response.data! as List).map((e) => Chapter.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load chapters from database');
    }
  }

  /// Get specific chapter with tests (offline mode)
  Future<Chapter> getChapter(int chapterId) async {
    final response = await _chapterService.getChapterById(chapterId);

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load chapter from database');
    }
  }
}