import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';
import 'ChapterState.dart';
// =============================================================================
// CHAPTER NOTIFIER
// =============================================================================

class ChapterNotifier extends StateNotifier<ChapterState> {
  ChapterNotifier() : super(const ChapterState());

  Future<void> loadChapters() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final chapters = await ApiService.getChapters();

      state = state.copyWith(
        chapters: chapters,
        isLoading: false,
      );

      Logger.info('Loaded ${chapters.length} chapters');
    } catch (e) {
      Logger.error('Failed to load chapters', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadChapterDetails(int chapterId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final chapter = await ApiService.getChapter(chapterId);

      state = state.copyWith(
        selectedChapter: chapter,
        isLoading: false,
      );

      Logger.info('Loaded chapter details: ${chapter.name}');
    } catch (e) {
      Logger.error('Failed to load chapter details', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSelectedChapter() {
    state = state.copyWith(clearSelectedChapter: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}