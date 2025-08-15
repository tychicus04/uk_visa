// lib/features/auth/screens/profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/states/AuthState.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: authState.user == null
            ? Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        )
            : CustomScrollView(
          slivers: [
            // Custom App Bar with Profile Header
            SliverAppBar(
              expandedHeight: 230,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
              iconTheme: IconThemeData(
                color: isDark ? AppColors.textPrimaryDark : Colors.white,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [AppColors.surfaceDark, AppColors.cardDark]
                          : AppColors.primaryGradient,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Avatar
                      Hero(
                        tag: 'profile-avatar',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? AppColors.shadowDark : Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark ? AppColors.primary : Colors.white,
                            child: Text(
                              authState.user!.fullName?.substring(0, 1).toUpperCase() ??
                                  authState.user!.email.substring(0, 1).toUpperCase(),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: isDark ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        authState.user!.fullName ?? 'User',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User Email
                      Text(
                        authState.user!.email,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Information Section
                    _buildSectionTitle(context, 'Account Information', isDark),
                    const SizedBox(height: 16),
                    _buildAccountInfoCard(context, authState, isDark),

                    const SizedBox(height: 32),

                    // Quick Actions Section
                    _buildSectionTitle(context, 'Quick Actions', isDark),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context, ref, isDark),

                    const SizedBox(height: 32),

                    // Logout Section
                    _buildLogoutSection(context, ref, l10n, authState, isDark),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, AuthState authState, bool isDark) {
    final theme = Theme.of(context);

    return Card(
      elevation: isDark ? 4 : 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shadowColor: isDark ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              label: 'Full Name',
              value: authState.user?.fullName ?? 'Not set',
              isDark: isDark,
            ),
            Divider(
              height: 24,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: authState.user?.email ?? '',
              isDark: isDark,
            ),
            Divider(
              height: 24,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            _buildInfoRow(
              context,
              icon: Icons.language_outlined,
              label: 'Language',
              value: 'English', // You can get this from user preferences
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required bool isDark,
        Color? valueColor,
      }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: isDark ? AppColors.iconDark : AppColors.iconLight,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, WidgetRef ref, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        required bool isDark,
      }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isDark ? 2 : 1,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shadowColor: isDark ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, WidgetRef ref, bool isDark) {
    return Card(
      elevation: isDark ? 4 : 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shadowColor: isDark ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () {
              // Navigate to notifications settings
            },
            isDark: isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'Change app language',
            onTap: () {
              // Navigate to language settings
            },
            isDark: isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'Light or dark mode',
            onTap: () {
              // Navigate to theme settings
            },
            isDark: isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help
            },
            isDark: isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              // Navigate to about
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        required bool isDark,
      }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.iconDark : AppColors.iconLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutSection(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      AuthState authState,
      bool isDark,
      ) {
    return Column(
      children: [
        // CustomButton(
        //   text: l10n.auth_logout,
        //   onPressed: authState.isLoading ? null : () async {
        //     await _showLogoutConfirmation(context, ref, isDark);
        //   },
        //   backgroundColor: AppColors.error,
        //   isLoading: authState.isLoading,
        //   icon: Icons.logout,
        // ),
        const SizedBox(height: 16),
        Text(
          'App Version 1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context, WidgetRef ref, bool isDark) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}