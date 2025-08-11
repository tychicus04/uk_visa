// lib/features/chapters/screens/chapter_reading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/custom_button.dart';
import '../data/chapter_content.dart';

class ChapterReadingScreen extends ConsumerStatefulWidget {
  final int chapterId;

  const ChapterReadingScreen({
    super.key,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterReadingScreen> createState() => _ChapterReadingScreenState();
}

class _ChapterReadingScreenState extends ConsumerState<ChapterReadingScreen> {
  late ScrollController _scrollController;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chapterContent = ChapterContent.getChapterContent(widget.chapterId);

    if (chapterContent == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chapter Not Found')),
        body: const Center(
          child: Text('Chapter content not available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with Progress
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'CHAPTER ${widget.chapterId}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _showChapterMenu(context),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(8),
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: _scrollProgress,
                  backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Chapter Title
                Text(
                  chapterContent.title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 24),

                // Chapter Image (if available)
                if (chapterContent.imageUrl != null) ...[
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(chapterContent.imageUrl!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (chapterContent.imageCaption != null)
                    Text(
                      chapterContent.imageCaption!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                ],

                // Content Sections
                ...chapterContent.sections.map((section) => _buildSection(
                  context,
                  section,
                )),

                const SizedBox(height: 32),

                // Key Points Summary
                if (chapterContent.keyPoints.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Key Points to Remember',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...chapterContent.keyPoints.map((point) =>
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(top: 8, right: 12),
                                    decoration: const BoxDecoration(
                                      color: AppColors.info,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Practice',
                        onPressed: () {
                          context.go('/tests?chapter=${widget.chapterId}');
                        },
                        icon: Icons.quiz,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Next Chapter',
                        onPressed: widget.chapterId < 5 ? () {
                          context.go('/chapters/${widget.chapterId + 1}/read');
                        } : null,
                        isOutlined: true,
                        icon: Icons.arrow_forward,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100), // Bottom padding for navigation
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, ChapterSection section) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title.isNotEmpty) ...[
          Text(
            section.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
        ],

        ...section.paragraphs.map((paragraph) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
        ),

        if (section.bulletPoints.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...section.bulletPoints.map((point) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 10, right: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  void _showChapterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Bookmark This Section'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement bookmarking

              },
            ),
            ListTile(
              leading: const Icon(Icons.text_increase),
              title: const Text('Adjust Text Size'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement text size adjustment
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Chapter'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sharing
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Chapter Tests'),
              onTap: () {
                Navigator.pop(context);
                context.go('/tests?chapter=${widget.chapterId}');
              },
            ),
          ],
        ),
      ),
    );
  }
}