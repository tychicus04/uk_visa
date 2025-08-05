import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/UserStats.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_providers.dart';
import '../../data/models/User.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;
    

    if (user == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading profile...'),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.myProfile,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(authNotifierProvider.notifier).refreshProfile(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile Header
              AnimationConfiguration.staggeredList(
                position: 0,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildProfileHeader(user),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Card
              AnimationConfiguration.staggeredList(
                position: 1,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildStatisticsCard(user),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Progress Card
              if (user.stats != null) ...[
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: _buildProgressCard(user.stats!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Premium Status Card
              AnimationConfiguration.staggeredList(
                position: 3,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildPremiumStatusCard(user),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Account Actions
              AnimationConfiguration.staggeredList(
                position: 4,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildAccountActionsCard(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // App Actions
              AnimationConfiguration.staggeredList(
                position: 5,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildAppActionsCard(),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    _getInitials(user.fullName ?? user.email),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user.hasActiveSubscription)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(AppColors.premiumGold),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              user.fullName ?? user.email.split('@')[0],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.hasActiveSubscription
                    ? const Color(AppColors.premiumGold).withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.hasActiveSubscription ? 'PREMIUM MEMBER' : 'FREE MEMBER',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: user.hasActiveSubscription
                      ? const Color(AppColors.premiumGold)
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.editProfile),
                icon: const Icon(Icons.edit),
                label: Text(l10n.editProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(User user) {
    final stats = user.stats;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statistics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.totalAttempts,
                    '${stats?.totalAttempts ?? 0}',
                    Icons.quiz_outlined,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tests Passed',
                    '${stats?.passedAttempts ?? 0}',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.bestScore,
                    '${stats?.bestScore.toStringAsFixed(1) ?? '0'}%',
                    Icons.star_outline,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.averageScore,
                    '${stats?.averageScore.toStringAsFixed(1) ?? '0'}%',
                    Icons.trending_up_outlined,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            if (!user.hasActiveSubscription) ...[
              const SizedBox(height: 16),
              _buildFreeTestsInfo(user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFreeTestsInfo(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.freeTestsRemaining(user.remainingFreeTests),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Used ${user.freeTestsUsed} of ${user.freeTestsLimit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (user.remainingFreeTests == 0)
            TextButton(
              onPressed: () => context.push(AppRoutes.premium),
              child: Text(l10n.upgradeNow),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(UserStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // Progress Circle
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 6.0,
                  percent: (stats.averageScore / 100).clamp(0.0, 1.0),
                  center: Text(
                    '${stats.averageScore.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  progressColor: stats.averageScore >= 75 ? Colors.green : Colors.orange,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),

                const SizedBox(width: 24),

                // Progress Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Performance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.performanceLevel.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: stats.averageScore >= 75 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pass Rate: ${stats.passRate.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (stats.averageScore < 75) ...[
              const SizedBox(height: 12),
              Text(
                'Keep practicing to improve your average score to 75% or higher!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: user.hasActiveSubscription
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: const LinearGradient(
            colors: [
              Color(AppColors.premiumGradientStart),
              Color(AppColors.premiumGradientEnd),
            ],
          ),
        )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  user.hasActiveSubscription ? Icons.diamond : Icons.lock_outline,
                  color: user.hasActiveSubscription ? Colors.white : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  user.hasActiveSubscription ? 'Premium Status' : 'Premium Benefits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: user.hasActiveSubscription ? Colors.white : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (user.hasActiveSubscription) ...[
              Text(
                l10n.subscriptionActive,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              if (user.premiumExpiresAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.subscriptionExpires(_formatDate(user.premiumExpiresAt!)),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'Upgrade to Premium for unlimited access to all tests and features.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.premium),
                  child: Text(l10n.upgradeToPremium),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountSettings,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _buildActionItem(
              Icons.person_outline,
              l10n.editProfile,
              'Update your personal information',
                  () => context.push(AppRoutes.editProfile),
            ),

            _buildActionItem(
              Icons.lock_outline,
              l10n.changePassword,
              'Change your account password',
              _showChangePasswordDialog,
            ),

            _buildActionItem(
              Icons.history,
              l10n.testHistory,
              'View your test attempts',
                  () => context.push(AppRoutes.history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppActionsCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _buildActionItem(
              Icons.settings,
              l10n.settings,
              'App preferences and settings',
                  () => context.push(AppRoutes.settings),
            ),

            _buildActionItem(
              Icons.star_outline,
              l10n.rateApp,
              'Rate us on the app store',
              _rateApp,
            ),

            _buildActionItem(
              Icons.share,
              l10n.shareApp,
              'Share with friends',
              _shareApp,
            ),

            _buildActionItem(
              Icons.help_outline,
              l10n.support,
              'Get help and support',
              _contactSupport,
            ),

            _buildActionItem(
              Icons.logout,
              l10n.logout,
              'Sign out of your account',
              _showLogoutConfirmation,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showChangePasswordDialog() {
    // TODO: Implement change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Change password feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _rateApp() {
    // TODO: Implement app rating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your support!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _shareApp() {
    // TODO: Implement app sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share UK Visa Test with your friends!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _contactSupport() {
    // TODO: Implement support contact
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact support at ${AppConstants.supportEmail}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showLogoutConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }
}