// lib/features/auth/screens/login_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/error_handler.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // ✅ Listen to auth state changes for automatic navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
    });
  }

  void _setupAuthListener() {
    // ✅ Listen to auth state and navigate when authenticated
    ref.listen<AuthState>(authProvider, (previous, next) {
      print('🔄 Auth state changed in LoginScreen - isAuth: ${next.isAuthenticated}, user: ${next.user?.email}');

      if (next.isAuthenticated && next.user != null && mounted) {
        // ✅ Navigate only if we're coming from a non-authenticated state
        if (previous?.isAuthenticated != true) {
          print('➡️ Navigating to home from login');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/');
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Show loading overlay when authenticating
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // UK Flag and Title
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

                    // Welcome Back
                    Text(
                      l10n.auth_welcome,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your UK citizenship test preparation',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: l10n.auth_email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      enabled: !authState.isLoading, // ✅ Disable when loading
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

                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: l10n.auth_password,
                      obscureText: !_isPasswordVisible,
                      prefixIcon: Icons.lock_outlined,
                      enabled: !authState.isLoading, // ✅ Disable when loading
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: authState.isLoading ? null : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
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

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading ? null : () {
                          // Handle forgot password
                        },
                        child: Text(l10n.auth_forgotPassword),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    CustomButton(
                      text: l10n.auth_signIn,
                      onPressed: authState.isLoading ? null : () => _handleLogin(),
                      isLoading: authState.isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.auth_dontHaveAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: authState.isLoading ? null : () => context.go('/register'),
                          child: Text(l10n.auth_signUp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Loading overlay
          if (authState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingWidget(message: 'Signing in...'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print('🔐 Login button pressed');

    try {
      // ✅ Call login and let the auth listener handle navigation
      await ref.read(authProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('✅ Login completed successfully');

      // ✅ Navigation will be handled by the auth listener
      // No need for manual navigation here

    } catch (e) {
      print('❌ Login error: $e');

      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(e);

        // ✅ Show error using SnackBar
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