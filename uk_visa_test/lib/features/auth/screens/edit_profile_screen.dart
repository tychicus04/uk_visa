import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/states/AuthState.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.profile_editProfile,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.iconDark : AppColors.iconLight,
        ),
        actions: [
          TextButton(
            onPressed: authState.isLoading ? null : _saveProfile,
            child: Text(
              l10n.common_save,
              style: TextStyle(
                color: authState.isLoading
                    ? (isDark ? AppColors.disabledTextDark : AppColors.disabledTextLight)
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(context, l10n, authState, isDark),

              const SizedBox(height: 32),
              _buildSectionTitle(context, l10n.profile_personalInformation, isDark),
              const SizedBox(height: 16),
              _buildPersonalInfoCard(context, l10n, isDark),

              const SizedBox(height: 32),
              if (authState.isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                )
              else
                CustomButton(
                  text: l10n.profile_saveChanges,
                  onPressed: _saveProfile,
                  icon: Icons.save_outlined,
                ),

              const SizedBox(height: 24),
            ],
          ),
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

  Widget _buildAvatarSection(BuildContext context, AppLocalizations l10n, AuthState authState, bool isDark) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile-avatar',
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      authState.user?.fullName?.substring(0, 1).toUpperCase() ??
                          authState.user?.email.substring(0, 1).toUpperCase() ?? 'U',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _changeAvatar(l10n),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.profile_tapToChangePhoto,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, AppLocalizations l10n, bool isDark) => Card(
    elevation: isDark ? 4 : 2,
    color: isDark ? AppColors.cardDark : AppColors.cardLight,
    shadowColor: isDark ? AppColors.shadowDark : AppColors.shadowLight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              labelText: l10n.auth_fullName,
              labelStyle: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: isDark ? AppColors.iconDark : AppColors.iconLight,
              ),
              filled: true,
              fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.profile_validation_fullNameRequired;
              }
              if (value.trim().length < 2) {
                return l10n.profile_validation_nameMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            style: TextStyle(
              color: isDark ? AppColors.disabledTextDark : AppColors.disabledTextLight,
            ),
            decoration: InputDecoration(
              labelText: l10n.profile_emailAddress,
              labelStyle: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: isDark ? AppColors.iconDark : AppColors.iconLight,
              ),
              filled: true,
              fillColor: isDark ? AppColors.disabledDark : AppColors.disabledLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                ),
              ),
            ),
            enabled: false, // Usually email is not editable
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
  void _changeAvatar(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Implement avatar change functionality
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.profile_changeProfilePhoto,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  context,
                  l10n,
                  icon: Icons.camera_alt,
                  label: l10n.profile_camera,
                  onTap: () {
                    Navigator.pop(context);
                    // Implement camera functionality
                  },
                  isDark: isDark,
                ),
                _buildAvatarOption(
                  context,
                  l10n,
                  icon: Icons.photo_library,
                  label: l10n.profile_gallery,
                  onTap: () {
                    Navigator.pop(context);
                    // Implement gallery functionality
                  },
                  isDark: isDark,
                ),
                _buildAvatarOption(
                  context,
                  l10n,
                  icon: Icons.delete,
                  label: l10n.profile_remove,
                  onTap: () {
                    Navigator.pop(context);
                    // Implement remove functionality
                  },
                  isDark: isDark,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
      BuildContext context,
      AppLocalizations l10n, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required bool isDark,
      }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    try {
      await ref.read(authProvider.notifier).updateProfile(
        fullName: _fullNameController.text.trim(),
        languageCode: _selectedLanguage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profile_updateSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.profile_updateFailed}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}