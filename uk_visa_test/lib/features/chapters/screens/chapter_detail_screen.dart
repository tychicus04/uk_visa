// lib/features/chapters/screens/chapter_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../tests/widgets/test_card.dart';
import '../providers/chapter_provider.dart';

class ChapterDetailScreen extends ConsumerWidget {
  final int chapterId;

  const ChapterDetailScreen({
    super.key,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chapterState = ref.watch( chapterDetailProvider(chapterId));

    return chapterState.when(
      data: (chapter) => Scaffold(
        appBar: AppBar(
          title: Text('Chapter ${chapter.chapterNumber}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter Header
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

              // Chapter Tests
              if (chapter.tests != null && chapter.tests!.isNotEmpty) ...[
                Text(
                  'Chapter Tests',
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

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/chapters/${chapter.id}/read');
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Read Chapter'),
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
                          // Navigate to chapter tests
                          context.go('/tests?chapter=${chapter.id}');
                        },
                        icon: const Icon(Icons.quiz),
                        label: const Text('Practice Tests'),
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

