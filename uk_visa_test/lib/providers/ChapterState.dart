import '../data/models/Chapter.dart';

class ChapterState {
  final List<Chapter> chapters;
  final Chapter? selectedChapter;
  final bool isLoading;
  final String? error;

  const ChapterState({
    this.chapters = const [],
    this.selectedChapter,
    this.isLoading = false,
    this.error,
  });

  ChapterState copyWith({
    List<Chapter>? chapters,
    Chapter? selectedChapter,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedChapter = false,
  }) {
    return ChapterState(
      chapters: chapters ?? this.chapters,
      selectedChapter: clearSelectedChapter ? null : (selectedChapter ?? this.selectedChapter),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
