import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/AuthState.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_providers.dart';
import '../../utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AuthState>(authNotifierProvider, (previous, next) {
        if (next.isAuthenticated && !next.isLoading) {
          // Navigate to home on successful login
          context.go(AppRoutes.home);
        }

        if (next.error != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authNotifierProvider.notifier).login(
      email: email,
      password: password,
    );

    if (success && _rememberMe) {
      // Save login preferences if remember me is checked
      // This would typically save email or enable auto-login
    }
  }

  void _goToRegister() {
    context.go(AppRoutes.register);
  }

  void _forgotPassword() {
    // TODO: Implement forgot password functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Forgot password feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(AppColors.primaryColor),
              Color(AppColors.primaryDark),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // App Logo and Title
                  AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: AppConstants.longAnimation,
                    child: SlideAnimation(
                      verticalOffset: -50.0,
                      child: FadeInAnimation(
                        child: Column(
                          children: [
                            // App Logo
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 50,
                                color: Color(AppColors.primaryColor),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Welcome Title
                            Text(
                              l10n.loginTitle,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              l10n.loginSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login Form
                  Expanded(
                    child: AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: AppConstants.longAnimation,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.largePadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 20),

                                  // Email Field
                                  CustomTextField(
                                    controller: _emailController,
                                    label: l10n.email,
                                    hintText: 'Enter your email',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: Validators.email,
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field
                                  CustomTextField(
                                    controller: _passwordController,
                                    label: l10n.password,
                                    hintText: 'Enter your password',
                                    prefixIcon: Icons.lock_outlined,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    validator: Validators.password,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    onSubmitted: (_) => _login(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Remember Me & Forgot Password
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Remember me',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: _forgotPassword,
                                        child: Text(
                                          l10n.forgotPassword,
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  LoadingButton(
                                    onPressed: _login,
                                    isLoading: authState.isLoading,
                                    text: l10n.login,
                                  ),

                                  const SizedBox(height: 24),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          l10n.orContinueWith,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Social Login Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SocialLoginButton(
                                          onPressed: () {
                                            // TODO: Implement Google Sign In
                                          },
                                          icon: 'assets/icons/google.png',
                                          text: 'Google',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: SocialLoginButton(
                                          onPressed: () {
                                            // TODO: Implement Apple Sign In
                                          },
                                          icon: 'assets/icons/apple.png',
                                          text: 'Apple',
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Sign Up Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.dontHaveAccount,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      TextButton(
                                        onPressed: _goToRegister,
                                        child: Text(
                                          l10n.register,
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}