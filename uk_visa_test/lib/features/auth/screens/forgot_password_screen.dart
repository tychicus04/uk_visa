// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/error_handler.dart';
import '../../../data/enums/CustomButtonVariant.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/password_reset_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Reset state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(passwordResetProvider.notifier).resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final passwordResetState = ref.watch(passwordResetProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for errors
    ref.listen<PasswordResetState>(passwordResetProvider, (previous, next) {
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
            ref.read(passwordResetProvider.notifier).clearError();
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
          onPressed: passwordResetState.isLoading ? null : () => context.go('/login'),
        ),
        title: Text(l10n.forgotPassword_title),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
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
                            l10n.forgotPassword_title,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.forgotPassword_subtitle,
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

                    // Show success message if email was sent
                    if (passwordResetState.emailSent) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
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
                              Icons.mark_email_read,
                              color: AppColors.success,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.forgotPassword_emailSent,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.forgotPassword_checkEmail,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (passwordResetState.sentEmail != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                passwordResetState.sentEmail!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Resend button with cooldown
                      if (passwordResetState.isResendCooldown)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                l10n.forgotPassword_resendIn(passwordResetState.resendCooldownSeconds),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      else
                        CustomButton(
                          text: l10n.forgotPassword_resendEmail,
                          onPressed: () => _resendEmail(),
                          variant: CustomButtonVariant.outlined,
                          isLoading: passwordResetState.isLoading,
                        ),
                    ] else ...[
                      // Email input form
                      CustomTextField(
                        controller: _emailController,
                        labelText: l10n.auth_email,
                        hintText: l10n.forgotPassword_emailHint,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        enabled: !passwordResetState.isLoading,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return l10n.validation_emailRequired;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return l10n.validation_emailInvalid;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Send button
                      CustomButton(
                        text: l10n.forgotPassword_sendButton,
                        onPressed: passwordResetState.isLoading ? null : () => _sendForgotPasswordEmail(),
                        isLoading: passwordResetState.isLoading,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Back to login button
                    CustomButton(
                      text: l10n.forgotPassword_backToLogin,
                      onPressed: passwordResetState.isLoading ? null : () => context.go('/login'),
                      variant: CustomButtonVariant.text,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (passwordResetState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingWidget(message: 'Sending email...'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendForgotPasswordEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    await ref.read(passwordResetProvider.notifier).sendForgotPasswordEmail(email);
  }

  Future<void> _resendEmail() async {
    await ref.read(passwordResetProvider.notifier).resendForgotPasswordEmail();
  }
}