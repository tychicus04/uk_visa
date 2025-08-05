import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/AppLanguage.dart';
import '../../data/models/User.dart';
import '../../data/requests/UpdateProfileRequest.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/loading_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  AppLanguage _selectedLanguage = AppLanguage.english;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _selectedLanguage = AppLanguage.values.firstWhere(
            (lang) => lang.code == user.languageCode,
        orElse: () => AppLanguage.english,
      );
    }

    // Listen for changes
    _fullNameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      final hasNameChange = _fullNameController.text.trim() != (user.fullName ?? '');
      final hasLanguageChange = _selectedLanguage.code != user.languageCode;

      if (_hasChanges != (hasNameChange || hasLanguageChange)) {
        setState(() {
          _hasChanges = hasNameChange || hasLanguageChange;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
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
        title: l10n.editProfile,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                l10n.save,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile Avatar Section
              AnimationConfiguration.staggeredList(
                position: 0,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildAvatarSection(user),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Personal Information Section
              AnimationConfiguration.staggeredList(
                position: 1,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildPersonalInfoSection(user),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Language Preferences Section
              AnimationConfiguration.staggeredList(
                position: 2,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildLanguageSection(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Account Information Section
              AnimationConfiguration.staggeredList(
                position: 3,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildAccountInfoSection(user),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              AnimationConfiguration.staggeredList(
                position: 4,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _buildSaveButton(),
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

  Widget _buildAvatarSection(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            // Avatar with edit option
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    _getInitials(user.fullName ?? user.email),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user.hasActiveSubscription)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(AppColors.premiumGold),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _changeAvatar,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              l10n.tapToChangePhoto,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Full Name Field
            CustomTextField(
              controller: _fullNameController,
              label: l10n.fullName,
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: Validators.name,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _onFormChanged(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.languagePreference,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Language Dropdown
            DropdownButtonFormField<AppLanguage>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: l10n.selectLanguage,
                prefixIcon: const Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: AppLanguage.values.map((language) {
                return DropdownMenuItem<AppLanguage>(
                  value: language,
                  child: Row(
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(language.nativeName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (AppLanguage? value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  _onFormChanged();
                }
              },
            ),

            const SizedBox(height: 8),

            Text(
              'This will change the app language immediately.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Email (Read-only)
            _buildReadOnlyField(
              label: l10n.email,
              value: user.email,
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),

            // Member Since
            _buildReadOnlyField(
              label: 'Member Since',
              value: _formatDate(user.createdAt),
              icon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 16),

            // Account Status
            _buildAccountStatusField(user),

            const SizedBox(height: 16),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showChangePasswordDialog,
                icon: const Icon(Icons.lock_outline),
                label: Text(l10n.changePassword),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        filled: true,
      ),
      readOnly: true,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  Widget _buildAccountStatusField(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        color: user.hasActiveSubscription
            ? const Color(AppColors.premiumGold).withOpacity(0.1)
            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(
            user.hasActiveSubscription ? Icons.diamond : Icons.person_outline,
            color: user.hasActiveSubscription
                ? const Color(AppColors.premiumGold)
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Status',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.hasActiveSubscription ? 'PREMIUM MEMBER' : 'FREE MEMBER',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: user.hasActiveSubscription
                        ? const Color(AppColors.premiumGold)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (user.hasActiveSubscription && user.premiumExpiresAt != null)
                  Text(
                    'Expires: ${_formatDate(user.premiumExpiresAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: LoadingButton(
        onPressed: _hasChanges ? _saveProfile : null,
        isLoading: _isLoading,
        child: Text(
          l10n.saveChanges,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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

  void _changeAvatar() {
    // TODO: Implement avatar change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Photo upload feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateProfileRequest(
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        languageCode: _selectedLanguage.code,
      );

      await ref.read(authNotifierProvider.notifier).updateProfile(request);

      // Update app language if changed
      if (_selectedLanguage != ref.read(languageNotifierProvider)) {
        ref.read(languageNotifierProvider.notifier).setLanguage(_selectedLanguage);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdateError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Change Password Dialog Widget
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.changePassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Password
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_showCurrentPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              obscureText: !_showCurrentPassword,
              validator: Validators.required,
            ),

            const SizedBox(height: 16),

            // New Password
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              obscureText: !_showNewPassword,
              validator: Validators.password,
            ),

            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              obscureText: !_showConfirmPassword,
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        LoadingButton(
          onPressed: _changePassword,
          isLoading: _isLoading,
          child: Text(l10n.changePassword),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authNotifierProvider.notifier).changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}