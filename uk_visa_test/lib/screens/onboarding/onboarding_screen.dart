import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../utils/secure_storage.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_1.png',
      title: 'Welcome to UK Visa Test',
      description: 'Your complete guide to passing the Life in the UK Test',
      icon: Icons.school,
      gradient: const [
        Color(AppColors.primaryColor),
        Color(AppColors.primaryLight),
      ],
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_2.png',
      title: 'Comprehensive Practice',
      description: 'Practice with authentic questions covering all 5 chapters',
      icon: Icons.quiz,
      gradient: const [
        Color(AppColors.secondaryColor),
        Color(AppColors.secondaryLight),
      ],
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_3.png',
      title: 'Track Your Progress',
      description: 'Monitor your improvement with detailed statistics',
      icon: Icons.trending_up,
      gradient: const [
        Color(AppColors.accentColor),
        Color(AppColors.accentLight),
      ],
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_4.png',
      title: 'Expert Explanations',
      description: 'Learn from detailed explanations for every question',
      icon: Icons.lightbulb,
      gradient: const [
        Color(AppColors.successColor),
        Color(0xFF66BB6A),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: AppTheme.defaultCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: AppTheme.defaultCurve,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await SecureStorage.setOnboardingCompleted(true);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _pages[_currentPage].gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    // Page Indicator
                    Row(
                      children: List.generate(
                        _pages.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // Skip Button
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        l10n.skip,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: AppConstants.longAnimation,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: OnboardingPageWidget(
                            page: _pages[index],
                            size: size,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    _currentPage > 0
                        ? TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: Text(
                        l10n.back,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                        : const SizedBox(width: 80),

                    // Next/Get Started Button
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].gradient[0],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage < _pages.length - 1
                                ? l10n.next
                                : l10n.getStarted,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final Size size;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image Placeholder
          Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size.width * 0.3),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: size.width * 0.2,
              color: Colors.white,
            ),
          ),

          SizedBox(height: size.height * 0.08),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: size.height * 0.03),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}