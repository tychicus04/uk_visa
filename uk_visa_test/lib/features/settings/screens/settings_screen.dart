import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/providers/bilingual_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/remove_ads_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final bilingualState = ref.watch(bilingualProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Remove Ads Purchase Card
          const RemoveAdsCard(),
          const SizedBox(height: 24),

          // Language & Localization Section
          _buildSectionHeader('Appearance', theme),

          // Theme Setting
          _buildSettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: _getThemeModeText(themeMode),
            onTap: () => _showThemeDialog(context, ref),
            theme: theme,
          ),
          const SizedBox(height: 16),
          // Test Content Language Section
          _buildSectionHeader('Test Content Language', theme),

          // Bilingual Mode Toggle
          _buildSettingTile(
            icon: Icons.translate,
            title: 'Bilingual Mode',
            subtitle: bilingualState.isEnabled
                ? 'Show translations during tests'
                : 'English only',
            onTap: () => ref.read(bilingualProvider.notifier).toggleBilingual(),
            theme: theme,
            trailing: Switch.adaptive(
              value: bilingualState.isEnabled,
              onChanged: (value) => ref.read(bilingualProvider.notifier).setBilingualMode(value),
                            activeTrackColor: AppColors.primary,
            ),
          ),

          // Secondary Language Selection (only shown when bilingual is enabled)
          if (bilingualState.isEnabled) ...[
            _buildSettingTile(
              icon: Icons.public,
              title: 'Secondary Language',
              subtitle: '${ApiConstants.getLanguageFlag(bilingualState.secondaryLanguage)} ${ApiConstants.getLanguageName(bilingualState.secondaryLanguage)}',
              onTap: () => _showSecondaryLanguageDialog(context, ref),
              theme: theme,
            ),

            // Language Info Card
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bilingual Test Experience',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Questions and answers will be shown in English with ${ApiConstants.getLanguageName(bilingualState.secondaryLanguage)} translations below.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.info.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Language Availability Info (when bilingual is disabled)
          if (!bilingualState.isEnabled) ...[
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.translate,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available Languages',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ApiConstants.supportedSecondaryLanguages.map((code) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ApiConstants.getLanguageFlag(code),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ApiConstants.getLanguageName(code),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enable bilingual mode to access translations in your preferred language.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', theme),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App information',
            onTap: () => _showAboutDialog(context, theme),
            theme: theme,
          ),
          // _buildSettingTile(
          //   icon: Icons.privacy_tip_outlined,
          //   title: l10n.settings_privacy,
          //   subtitle: l10n.settings_privacy,
          //   onTap: () {
          //     // TODO: Open privacy policy
          //   },
          //   theme: theme,
          // ),
          // _buildSettingTile(
          //   icon: Icons.description_outlined,
          //   title: l10n.settings_terms,
          //   subtitle: l10n.settings_terms,
          //   onTap: () {
          //     // TODO: Open terms of service
          //   },
          //   theme: theme,
          // ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? textColor,
    Widget? trailing,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? (isDark ? AppColors.iconDark : AppColors.iconLight),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
      case ThemeMode.system:
        return 'System Theme';
    }
  }

  // Secondary Language Dialog (for test content)
  void _showSecondaryLanguageDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final availableLanguages = ref.read(availableSecondaryLanguagesProvider);
    final currentLanguage = ref.read(currentSecondaryLanguageProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Secondary Language',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a language for test translations',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: availableLanguages.map((language) {
                      final code = language['code']!;
                      final name = language['name']!;
                      final flag = language['flag']!;
                      final isSelected = currentLanguage == code;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: _buildLanguageOption(
                          context: context,
                          title: name,
                          subtitle: code.toUpperCase(),
                          flag: flag,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(bilingualProvider.notifier).setSecondaryLanguage(code);
                            Navigator.of(context).pop();
                          },
                          theme: theme,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String flag,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isSelected = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : Colors.grey[50]),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: isDark ? AppColors.borderDark : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Light Theme'),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Dark Theme'),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('System Theme'),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    showAboutDialog(
      context: context,
      applicationName: 'UK Visa Test',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 UK Visa Test',
      children: [
        const SizedBox(height: 16),
        Text(
            'Prepare for your Life in the UK Test with comprehensive practice questions and mock exams.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            )
        )
      ],
    );
  }
}
