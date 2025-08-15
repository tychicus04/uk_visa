// lib/features/chapters/providers/reading_progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';

final readingProgressProvider = StateNotifierProvider<ReadingProgressNotifier, Map<int, double>>((ref) => ReadingProgressNotifier());

class ReadingProgressNotifier extends StateNotifier<Map<int, double>> {
  ReadingProgressNotifier() : super({}) {
    _loadProgress();
  }

  void _loadProgress() {
    // Load reading progress from shared preferences
    // This is a simplified implementation
    state = {
      1: 1.0, // Chapter 1 completed
      2: 1.0, // Chapter 2 completed
      3: 0.6, // Chapter 3 60% read
      4: 0.0, // Chapter 4 not started
      5: 0.0, // Chapter 5 not started
    };
  }

  void updateProgress(int chapterId, double progress) {
    state = {
      ...state,
      chapterId: progress.clamp(0.0, 1.0),
    };
    _saveProgress();
  }

  void markChapterCompleted(int chapterId) {
    updateProgress(chapterId, 1.0);
  }

  void _saveProgress() {
    // Save to shared preferences
    // Implementation would use SharedPrefsService
  }

  double getProgress(int chapterId) {
    return state[chapterId] ?? 0.0;
  }

  bool isChapterCompleted(int chapterId) {
    return getProgress(chapterId) >= 1.0;
  }

  double get overallProgress {
    if (state.isEmpty) return 0.0;
    final total = state.values.fold(0.0, (sum, progress) => sum + progress);
    return total / state.length;
  }

  int get completedChapters {
    return state.values.where((progress) => progress >= 1.0).length;
  }

  int get totalChapters => 5;
}

// Provider for specific chapter progress
final chapterProgressProvider = Provider.family<double, int>((ref, chapterId) {
  final progress = ref.watch(readingProgressProvider);
  return progress[chapterId] ?? 0.0;
});

// Provider for overall reading statistics
final readingStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final progressNotifier = ref.watch(readingProgressProvider.notifier);
  final progress = ref.watch(readingProgressProvider);

  return {
    'overall_progress': progressNotifier.overallProgress,
    'completed_chapters': progressNotifier.completedChapters,
    'total_chapters': progressNotifier.totalChapters,
    'chapters_in_progress': progress.values.where((p) => p > 0.0 && p < 1.0).length,
    'next_chapter': _getNextChapterToRead(progress),
  };
});

int? _getNextChapterToRead(Map<int, double> progress) {
  for (int i = 1; i <= 5; i++) {
    final chapterProgress = progress[i] ?? 0.0;
    if (chapterProgress < 1.0) {
      return i;
    }
  }
  return null; // All chapters completed
}