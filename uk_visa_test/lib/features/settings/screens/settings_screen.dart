import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/bilingual_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final bilingualState = ref.watch(bilingualProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          _buildSectionHeader(l10n.auth_profile, theme),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: l10n.profile_editProfile,
            subtitle: l10n.profile_accountInformation,
            onTap: () => context.go('/settings/profile'),
            theme: theme,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.settings_appearance, theme), // ✅ Localized
          _buildSettingTile(
            icon: Icons.language,
            title: l10n.settings_language,
            subtitle: locale.languageCode == 'en' ? l10n.settings_english : l10n.settings_vietnamese, // ✅ Localized
            onTap: () => _showLanguageDialog(context, ref, l10n),
            theme: theme,
          ),
          _buildSettingTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.settings_theme,
            subtitle: _getThemeModeText(themeMode, l10n),
            onTap: () => _showThemeDialog(context, ref, l10n),
            theme: theme,
          ),

          _buildSettingTile(
            icon: Icons.translate,
            title: l10n.vietnamese_languageSupport,
            subtitle: bilingualState.isEnabled
                ? l10n.vietnamese_translationsEnabled
                : l10n.vietnamese_showTranslations,
            onTap: () => ref.read(bilingualProvider.notifier).toggleBilingual(),
            theme: theme,
            trailing: Switch.adaptive(
              value: bilingualState.isEnabled,
              onChanged: (value) => ref.read(bilingualProvider.notifier).setBilingualMode(value),
              activeColor: AppColors.info,
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(l10n.settings_about, theme),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: l10n.settings_about,
            subtitle: l10n.app_information,
            onTap: () => _showAboutDialog(context, l10n, theme),
            theme: theme,
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.settings_privacy,
            subtitle: l10n.settings_privacy,
            onTap: () {
              // TODO: Open privacy policy
            },
            theme: theme,
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: l10n.settings_terms,
            subtitle: l10n.settings_terms,
            onTap: () {
              // TODO: Open terms of service
            },
            theme: theme,
          ),
          const SizedBox(height: 24),
          _buildSettingTile(
            icon: Icons.logout,
            title: l10n.auth_logout,
            onTap: () => _showLogoutDialog(context, ref, l10n, theme),
            theme: theme,
            textColor: AppColors.error,
          ),
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

  String _getThemeModeText(ThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.settings_lightTheme;
      case ThemeMode.dark:
        return l10n.settings_darkTheme;
      case ThemeMode.system:
        return l10n.settings_systemTheme;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.settings_english), // ✅ Localized
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.settings_vietnamese), // ✅ Localized
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('vi'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.settings_lightTheme),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.settings_darkTheme),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.settings_systemTheme),
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

  void _showAboutDialog(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: l10n.appVersion,
      applicationLegalese: l10n.appCopyright,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.appAbout,
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.auth_logout),
        content: Text(
          l10n.logout_confirmation,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                onPressed: () => Navigator.of(context).pop(),
                text: l10n.common_cancel,
              ),
              CustomButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(authProvider.notifier).logout();
                },
                text: l10n.auth_logout, // ✅ Localized
                backgroundColor: AppColors.error,
                textColor: Colors.white,
              ),
            ],
          )
        ],
      ),
    );
  }
}