import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/AppLanguage.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/AppSettings.dart';
import '../../providers/NotificationSettings.dart';
import '../../providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.settings),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // App Preferences
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildAppPreferencesSection(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notifications
            AnimationConfiguration.staggeredList(
              position: 1,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildNotificationsSection(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Privacy & Security
            AnimationConfiguration.staggeredList(
              position: 2,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildPrivacySection(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // About & Support
            AnimationConfiguration.staggeredList(
              position: 3,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildAboutSection(),
                ),
              ),
            ),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreferencesSection() {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(themeNotifierProvider);
    final currentLanguage = ref.watch(languageNotifierProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appSettings,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Theme Setting
            ListTile(
              leading: Icon(
                _getThemeIcon(currentTheme as AppTheme),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.theme),
              subtitle: Text(_getThemeLabel(currentTheme as AppTheme)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showThemeDialog(),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Language Setting
            ListTile(
              leading: Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.language),
              subtitle: Text('${currentLanguage.flag} ${currentLanguage.name}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageDialog(),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Sound Effects
            SwitchListTile(
              secondary: Icon(
                Icons.volume_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.soundEffects),
              subtitle: const Text('Play sounds for interactions'),
              value: appSettings.soundEffects,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).toggleSoundEffects();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Vibration
            SwitchListTile(
              secondary: Icon(
                Icons.vibration,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.vibration),
              subtitle: const Text('Vibrate for feedback'),
              value: appSettings.vibration,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).toggleVibration();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notifications,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Push Notifications
            SwitchListTile(
              secondary: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.pushNotifications),
              subtitle: const Text('Receive push notifications'),
              value: notificationSettings.pushNotifications,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).togglePushNotifications();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Email Notifications
            SwitchListTile(
              secondary: Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.emailNotifications),
              subtitle: const Text('Receive email updates'),
              value: notificationSettings.emailNotifications,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).toggleEmailNotifications();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Study Reminders
            SwitchListTile(
              secondary: Icon(
                Icons.schedule,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.studyReminders),
              subtitle: const Text('Daily study reminders'),
              value: notificationSettings.studyReminders,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).toggleStudyReminders();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Test Reminders
            SwitchListTile(
              secondary: Icon(
                Icons.quiz,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.testReminders),
              subtitle: const Text('Reminders to take practice tests'),
              value: notificationSettings.testReminders,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).toggleTestReminders();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Achievement Notifications
            SwitchListTile(
              secondary: Icon(
                Icons.emoji_events,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.achievementNotifications),
              subtitle: const Text('Celebrate your achievements'),
              value: notificationSettings.achievementNotifications,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).toggleAchievementNotifications();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    final appSettings = ref.watch(appSettingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacy,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Biometric Login
            SwitchListTile(
              secondary: Icon(
                Icons.fingerprint,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.biometricLogin),
              subtitle: const Text('Use fingerprint or face ID'),
              value: appSettings.biometricLogin,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).toggleBiometricLogin();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Auto Login
            SwitchListTile(
              secondary: Icon(
                Icons.login,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.autoLogin),
              subtitle: const Text('Stay logged in'),
              value: appSettings.autoLogin,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).toggleAutoLogin();
              },
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Data Sync
            SwitchListTile(
              secondary: Icon(
                Icons.sync,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.dataSync),
              subtitle: const Text('Sync data across devices'),
              value: appSettings.dataSync,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).toggleDataSync();
              },
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Privacy Policy
            ListTile(
              leading: Icon(
                Icons.privacy_tip,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.privacyPolicy),
              subtitle: const Text('Read our privacy policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openPrivacyPolicy(),
              contentPadding: EdgeInsets.zero,
            ),

            // Terms of Service
            ListTile(
              leading: Icon(
                Icons.description,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.termsOfService),
              subtitle: const Text('Read our terms of service'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openTermsOfService(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.about,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // App Version
            ListTile(
              leading: Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.version),
              subtitle: Text(_packageInfo?.version ?? 'Loading...'),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Contact Support
            ListTile(
              leading: Icon(
                Icons.support_agent,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.contactUs),
              subtitle: const Text('Get help and support'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _contactSupport(),
              contentPadding: EdgeInsets.zero,
            ),

            // Rate App
            ListTile(
              leading: Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.rateApp),
              subtitle: const Text('Rate us on the app store'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _rateApp(),
              contentPadding: EdgeInsets.zero,
            ),

            // Share App
            ListTile(
              leading: Icon(
                Icons.share,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.shareApp),
              subtitle: const Text('Share with friends and family'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _shareApp(),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Clear Cache
            ListTile(
              leading: Icon(
                Icons.cleaning_services,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showClearCacheDialog(),
              contentPadding: EdgeInsets.zero,
            ),

            // Reset Settings
            ListTile(
              leading: const Icon(
                Icons.refresh,
                color: Colors.orange,
              ),
              title: const Text('Reset Settings'),
              subtitle: const Text('Reset all settings to default'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showResetSettingsDialog(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeLabel(AppTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppTheme.light:
        return l10n.lightTheme;
      case AppTheme.dark:
        return l10n.darkTheme;
      case AppTheme.system:
        return l10n.systemTheme;
    }
  }

  void _showThemeDialog() {
    final currentTheme = ref.read(themeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.values.map((theme) {
            return RadioListTile<AppTheme>(
              title: Text(_getThemeLabel(theme)),
              value: theme,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeNotifierProvider.notifier).setTheme(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final currentLanguage = ref.read(languageNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            return RadioListTile<AppLanguage>(
              title: Text('${language.flag} ${language.name}'),
              value: language,
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(languageNotifierProvider.notifier).setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data and free up storage space. Your account and test history will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('This will reset all app settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${AppConstants.privacyPolicyUrl}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _openTermsOfService() {
    // TODO: Open terms of service URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${AppConstants.termsOfServiceUrl}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _contactSupport() {
    // TODO: Open support contact
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact us at ${AppConstants.supportEmail}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _rateApp() {
    // TODO: Open app store rating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you for rating our app!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _shareApp() {
    // TODO: Share app functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share UK Visa Test with your friends!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _clearCache() {
    // TODO: Implement cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cache cleared successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetSettings() {
    // Reset all settings to defaults
    ref.read(themeNotifierProvider.notifier).setTheme(AppTheme.system);
    ref.read(languageNotifierProvider.notifier).setLanguage(AppLanguage.english);
    ref.read(appSettingsProvider.notifier).updateSettings(const AppSettings());
    ref.read(notificationSettingsProvider.notifier).updateSettings(const NotificationSettings());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings reset to defaults'),
        backgroundColor: Colors.green,
      ),
    );
  }
}