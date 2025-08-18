import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../tests/widgets/test_card.dart';
import '../providers/chapter_provider.dart';

class ChapterDetailScreen extends ConsumerWidget {

  const ChapterDetailScreen({
    required this.chapterId, super.key,
  });
  final int chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chapterState = ref.watch( chapterDetailProvider(chapterId));

    return chapterState.when(
      data: (chapter) => Scaffold(
        appBar: AppBar(
          title: Text('${l10n.chapter} ${chapter.chapterNumber}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (chapter.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  chapter.description!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (chapter.tests != null && chapter.tests!.isNotEmpty) ...[
                Text(
                  l10n.chapter_tests,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...chapter.tests!.map((test) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TestCard(
                    test: test,
                    onTap: () {
                      context.go('/tests/${test.id}');
                    },
                  ),
                )),

                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/chapters/${chapter.id}/read');
                      },
                      icon: const Icon(Icons.menu_book),
                      label: Text(l10n.read_chapter),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (chapter.tests != null && chapter.tests!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.go('/tests?chapter=${chapter.id}');
                        },
                        icon: const Icon(Icons.quiz),
                        label: Text(l10n.practice_tests),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(chapterDetailProvider(chapterId)),
        ),
      ),
    );
  }
}

