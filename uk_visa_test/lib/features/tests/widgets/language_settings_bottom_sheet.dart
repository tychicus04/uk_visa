// lib/features/tests/widgets/language_settings_bottom_sheet.dart - FIXED Overflow Issue
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/providers/bilingual_provider.dart';
import '../../../core/constants/api_constants.dart';

class LanguageSettingsBottomSheet extends ConsumerWidget {
  const LanguageSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bilingualState = ref.watch(bilingualProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final availableLanguages = ref.watch(availableSecondaryLanguagesProvider);

    // Get screen height for proper constraints
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // Use max 85% of screen height

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: Use minimum size
        children: [
          // Handle Bar (Fixed)
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header (Fixed)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.language,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Language Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bilingual Mode Toggle
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.translate,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bilingual Mode',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: bilingualState.isEnabled,
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) {
                                ref.read(bilingualProvider.notifier).setBilingualMode(value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          bilingualState.isEnabled
                              ? 'Show translations alongside English text to help you learn'
                              : 'Translations are currently disabled. Enable to see questions in your language',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Secondary Language Selection (Only shown when bilingual is enabled)
                  if (bilingualState.isEnabled) ...[
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Secondary Language',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Language selection cards with constrained height
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.35, // Limit to 35% of screen height
                          ),
                          child: ListView.builder(
                            shrinkWrap: true, // Important for nested scrolling
                            itemCount: availableLanguages.length,
                            itemBuilder: (context, index) {
                              final language = availableLanguages[index];
                              final isSelected = language['code'] == bilingualState.secondaryLanguage;
                              final isFirst = index == 0;
                              final isLast = index == availableLanguages.length - 1;

                              return _buildLanguageOption(
                                context,
                                ref,
                                language,
                                isSelected,
                                isFirst,
                                isLast,
                                theme,
                                isDark,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Translation Quality Info
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      title: 'Professional Translation',
                      description: 'All translations are professionally verified for accuracy and clarity',
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ],

                  // Bottom padding for scroll
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Done Button (Fixed at bottom)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Done',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Safe area padding for bottom
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build language selection option (fixed for better constraints)
  Widget _buildLanguageOption(
      BuildContext context,
      WidgetRef ref,
      Map<String, String> language,
      bool isSelected,
      bool isFirst,
      bool isLast,
      ThemeData theme,
      bool isDark,
      ) {
    final code = language['code']!;
    final name = language['name']!;
    final flag = language['flag']!;

    return InkWell(
      onTap: () {
        ref.read(bilingualProvider.notifier).setSecondaryLanguage(code);
      },
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isFirst ? 12 : 0),
        bottom: Radius.circular(isLast ? 12 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(
          minHeight: 56, // Minimum touch target
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: !isLast ? Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderDark : Colors.grey[200]!,
              width: 1,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            // Language flag
            SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Language name
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            ),

            // Language code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.surfaceDark : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Selection indicator
            SizedBox(
              width: 20,
              height: 20,
              child: isSelected
                  ? Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : Colors.grey[400]!,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info card widget with localized content
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withValues(alpha: 0.3),
        width: 1,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to top for long text
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use minimum size
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}