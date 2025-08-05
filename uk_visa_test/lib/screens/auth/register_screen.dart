import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../providers/AuthState.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_providers.dart';
import '../../utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AuthState>(authNotifierProvider, (previous, next) {
        if (next.isAuthenticated && !next.isLoading) {
          // Navigate to home on successful registration
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

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.agreeToTerms),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final currentLanguage = ref.read(languageNotifierProvider);

    final success = await ref.read(authNotifierProvider.notifier).register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      languageCode: currentLanguage.code,
    );

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _goToLogin() {
    context.go(AppRoutes.login);
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
                  const SizedBox(height: 20),

                  // Header
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
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 40,
                                color: Color(AppColors.primaryColor),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Title
                            Text(
                              l10n.registerTitle,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              l10n.registerSubtitle,
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

                  const SizedBox(height: 30),

                  // Registration Form
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
                                  const SizedBox(height: 10),

                                  // Full Name Field
                                  CustomTextField(
                                    controller: _fullNameController,
                                    label: l10n.fullName,
                                    hintText: 'Enter your full name',
                                    prefixIcon: Icons.person_outline,
                                    textInputAction: TextInputAction.next,
                                    validator: Validators.name,
                                  ),

                                  const SizedBox(height: 16),

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

                                  const SizedBox(height: 16),

                                  // Password Field
                                  CustomTextField(
                                    controller: _passwordController,
                                    label: l10n.password,
                                    hintText: 'Enter your password',
                                    prefixIcon: Icons.lock_outlined,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
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
                                  ),

                                  const SizedBox(height: 16),

                                  // Confirm Password Field
                                  CustomTextField(
                                    controller: _confirmPasswordController,
                                    label: l10n.confirmPassword,
                                    hintText: 'Confirm your password',
                                    prefixIcon: Icons.lock_outlined,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    validator: (value) => Validators.confirmPassword(
                                      value,
                                      _passwordController.text,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    onSubmitted: (_) => _register(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Terms Agreement
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _agreeToTerms = !_agreeToTerms;
                                            });
                                          },
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'I agree to the ',
                                              style: theme.textTheme.bodySmall,
                                              children: [
                                                TextSpan(
                                                  text: l10n.termsOfService,
                                                  style: TextStyle(
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const TextSpan(text: ' and '),
                                                TextSpan(
                                                  text: l10n.privacyPolicy,
                                                  style: TextStyle(
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Register Button
                                  LoadingButton(
                                    onPressed: _register,
                                    isLoading: authState.isLoading,
                                    text: l10n.register,
                                  ),

                                  const Spacer(),

                                  // Login Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.alreadyHaveAccount,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      TextButton(
                                        onPressed: _goToLogin,
                                        child: Text(
                                          l10n.login,
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
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