import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/error/error_handler.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String? _redirectPath;

  @override
  void initState() {
    super.initState();
    // Get redirect parameter from URL when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      _redirectPath = uri.queryParameters['redirect'];
      print('LoginScreen - Redirect path: $_redirectPath');
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Remove the old auth listener since we'll handle redirect in the provider now
    // The AuthNotifier will handle the redirect automatically

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                    const SizedBox(height: 40),
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
                              child: Image.asset(
                                'assets/images/uk_flag.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.flag, color: AppColors.ukBlue, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.appTitle,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.britishCitizenshipTest,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      l10n.auth_welcome,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.sign_in_to_continue_your_test,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),

                    // Show redirect notification if applicable
                    if (_redirectPath != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
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
                                    'Sign in required',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'You need to sign in to access ${_getRedirectDescription()}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.info.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.person_outline,
                      enabled: !authState.isLoading,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Username is required';
                        }
                        if (value!.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    CustomButton(
                      text: l10n.auth_signIn,
                      onPressed: authState.isLoading ? null : () => _handleLogin(),
                      isLoading: authState.isLoading,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.auth_dontHaveAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: authState.isLoading ? null : () {
                            // Pass redirect to register screen too
                            final registerPath = _redirectPath != null
                                ? '/register?redirect=${Uri.encodeComponent(_redirectPath!)}'
                                : '/register';
                            context.go(registerPath);
                          },
                          child: Text(l10n.auth_signUp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (authState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: LoadingWidget(message: l10n.auth_signingIn),
              ),
            ),
        ],
      ),
    );
  }

  String _getRedirectDescription() {
    if (_redirectPath == null) return '';

    if (_redirectPath!.startsWith('/tests')) {
      return 'practice tests';
    } else if (_redirectPath!.startsWith('/test-taking')) {
      return 'the test session';
    } else if (_redirectPath!.startsWith('/settings/profile')) {
      return 'your profile settings';
    } else if (_redirectPath!.contains('result')) {
      return 'test results';
    }

    return 'this feature';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Pass context and redirectPath to the updated auth provider
      await ref.read(authProvider.notifier).login(
        username: _usernameController.text.trim(),
        context: context,
        redirectPath: _redirectPath,
      );

      // Success - the AuthNotifier will handle the redirect automatically
      print('Login successful - redirect will be handled by AuthNotifier');

    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}