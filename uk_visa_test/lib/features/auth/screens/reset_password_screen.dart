// lib/features/auth/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/enums/CustomButtonVariant.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/password_reset_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Reset state and verify token when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resetPasswordProvider.notifier).resetState();
      ref.read(resetPasswordProvider.notifier).verifyResetToken(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for errors and success
    ref.listen<ResetPasswordState>(resetPasswordProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        // Clear error after showing
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(resetPasswordProvider.notifier).clearError();
          }
        });
      }

      // Navigate to login on successful password reset
      if (next.passwordReset && previous?.passwordReset != true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.resetPassword_successMessage),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: Text(l10n.resetPassword_title),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const Icon(
                              Icons.lock_reset,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.resetPassword_title,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.resetPassword_subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Show token verification status
                  if (resetPasswordState.isVerifyingToken) ...[
                    const Center(
                      child: LoadingWidget(message: 'Verifying reset link...'),
                    ),
                  ] else if (!resetPasswordState.isTokenValid) ...[
                    // Invalid token UI
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.resetPassword_invalidToken,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: l10n.resetPassword_requestNewLink,
                            onPressed: () => context.go('/forgot-password'),
                            variant: CustomButtonVariant.outlined,
                          ),
                        ],
                      ),
                    ),
                  ] else if (resetPasswordState.passwordReset) ...[
                    // Success UI
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.resetPassword_successMessage,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: l10n.resetPassword_goToLogin,
                            onPressed: () => context.go('/login'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Reset password form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Show email if available
                          if (resetPasswordState.tokenEmail != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      resetPasswordState.tokenEmail!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // New password field
                          CustomTextField(
                            controller: _newPasswordController,
                            labelText: l10n.auth_newPassword,
                            hintText: l10n.resetPassword_newPasswordHint,
                            obscureText: !_isNewPasswordVisible,
                            prefixIcon: Icons.lock_outlined,
                            enabled: !resetPasswordState.isLoading,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: resetPasswordState.isLoading ? null : () {
                                setState(() {
                                  _isNewPasswordVisible = !_isNewPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return l10n.validation_passwordRequired;
                              }
                              if (value!.length < 6) {
                                return l10n.validation_passwordTooShort;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm password field
                          CustomTextField(
                            controller: _confirmPasswordController,
                            labelText: l10n.auth_confirmPassword,
                            hintText: l10n.resetPassword_confirmPasswordHint,
                            obscureText: !_isConfirmPasswordVisible,
                            prefixIcon: Icons.lock_outlined,
                            enabled: !resetPasswordState.isLoading,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: resetPasswordState.isLoading ? null : () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return l10n.validation_passwordRequired;
                              }
                              if (value != _newPasswordController.text) {
                                return l10n.validation_passwordMismatch;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Reset button
                          CustomButton(
                            text: l10n.resetPassword_resetButton,
                            onPressed: resetPasswordState.isLoading ? null : () => _resetPassword(),
                            isLoading: resetPasswordState.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Back to login
                  if (!resetPasswordState.passwordReset)
                    CustomButton(
                      text: l10n.forgotPassword_backToLogin,
                      onPressed: resetPasswordState.isLoading ? null : () => context.go('/login'),
                      variant: CustomButtonVariant.text,
                    ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (resetPasswordState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingWidget(message: 'Resetting password...'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text;
    await ref.read(resetPasswordProvider.notifier).resetPassword(
      token: widget.token,
      newPassword: newPassword,
    );
  }
}