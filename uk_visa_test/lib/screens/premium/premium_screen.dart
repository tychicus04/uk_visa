import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/SubscriptionPlan.dart';
import '../../data/models/User.dart';
import '../../providers/AuthState.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/loading_button.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen>
    with TickerProviderStateMixin {
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _selectedPlanId = 'yearly'; // Default to yearly
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadPlans();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await ApiService.getSubscriptionPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Use fallback plans if API fails
        _plans = _getFallbackPlans();
      }
    }
  }

  List<SubscriptionPlan> _getFallbackPlans() {
    return [
      SubscriptionPlan(
        id: 'monthly',
        name: 'Monthly Premium',
        price: 9.99,
        currency: 'USD',
        duration: 30,
        features: [
          'Unlimited test attempts',
          'All premium tests',
          'Detailed explanations',
          'Progress tracking',
          'Priority support',
          'Ad-free experience',
        ],
      ),
      SubscriptionPlan(
        id: 'yearly',
        name: 'Yearly Premium',
        price: 79.99,
        currency: 'USD',
        duration: 365,
        discount: '33% OFF',
        popular: true,
        features: [
          'All monthly features',
          'Save \$40 per year',
          'Bonus practice materials',
          'Early access to new tests',
          'Premium badge',
          'Exclusive content',
        ],
      ),
      SubscriptionPlan(
        id: 'lifetime',
        name: 'Lifetime Access',
        price: 199.99,
        currency: 'USD',
        features: [
          'All premium features',
          'Lifetime updates',
          'No recurring fees',
          'Best value option',
          'Premium support',
          'Future feature access',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.premium,
        backgroundColor: const Color(AppColors.premiumGold),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading plans...')
          : Column(
        children: [
          // Header
          _buildHeader(user?.hasActiveSubscription ?? false),

          // Plans
          Expanded(
            child: _buildPlansContent(),
          ),

          // Bottom Action
          if (!(_authState.user?.hasActiveSubscription ?? false))
            _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isPremiumUser) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(AppColors.premiumGradientStart),
            Color(AppColors.premiumGradientEnd),
          ],
        ),
      ),
      child: Column(
        children: [
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: -30.0,
              child: FadeInAnimation(
                child: Icon(
                  isPremiumUser ? Icons.diamond : Icons.stars,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          AnimationConfiguration.staggeredList(
            position: 1,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: -20.0,
              child: FadeInAnimation(
                child: Text(
                  isPremiumUser
                      ? 'You\'re Premium!'
                      : l10n.upgradeToPremium,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          AnimationConfiguration.staggeredList(
            position: 2,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: -10.0,
              child: FadeInAnimation(
                child: Text(
                  isPremiumUser
                      ? 'Enjoy unlimited access to all premium features'
                      : 'Unlock unlimited tests and advanced features',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansContent() {
    final user = ref.watch(authNotifierProvider).user;
    final l10n = AppLocalizations.of(context)!;

    if (user?.hasActiveSubscription == true) {
      return _buildCurrentSubscription(user!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Premium Features
          _buildPremiumFeatures(),

          const SizedBox(height: 24),

          // Plans
          Text(
            l10n.choosePlan,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Plan Cards
          ..._plans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            return AnimationConfiguration.staggeredList(
              position: index + 3,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildPlanCard(plan),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildCurrentSubscription(User user) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Current Status Card
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                gradient: const LinearGradient(
                  colors: [
                    Color(AppColors.premiumGradientStart),
                    Color(AppColors.premiumGradientEnd),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.diamond,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.subscriptionActive,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (user.premiumExpiresAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.subscriptionExpires(_formatDate(user.premiumExpiresAt!)),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Premium Features (what they have access to)
          _buildPremiumFeatures(showAsActive: true),

          const SizedBox(height: 24),

          // Manage Subscription Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _manageSubscription,
              icon: const Icon(Icons.settings),
              label: const Text('Manage Subscription'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures({bool showAsActive = false}) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      _PremiumFeature(
        icon: Icons.all_inclusive,
        title: l10n.unlimitedTests,
        description: 'Take as many tests as you want',
      ),
      _PremiumFeature(
        icon: Icons.diamond,
        title: l10n.allPremiumTests,
        description: 'Access to comprehensive and exam tests',
      ),
      _PremiumFeature(
        icon: Icons.lightbulb_outline,
        title: l10n.detailedExplanations,
        description: 'Learn why answers are correct or incorrect',
      ),
      _PremiumFeature(
        icon: Icons.analytics_outlined,
        title: l10n.progressTracking,
        description: 'Detailed statistics and performance analysis',
      ),
      _PremiumFeature(
        icon: Icons.support_agent,
        title: l10n.prioritySupport,
        description: 'Get help when you need it',
      ),
      _PremiumFeature(
        icon: Icons.block,
        title: l10n.adFree,
        description: 'Enjoy uninterrupted learning',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showAsActive ? 'Your Premium Benefits' : l10n.premiumFeatures,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            ...features.map((feature) => _buildFeatureItem(feature, showAsActive)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(_PremiumFeature feature, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(AppColors.premiumGold).withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: isActive
                  ? const Color(AppColors.premiumGold)
                  : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isPopular = plan.popular;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanId = plan.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? AppTheme.cardShadow : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Header
                  Row(
                    children: [
                      // Selection Indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        )
                            : null,
                      ),

                      const SizedBox(width: 12),

                      // Plan Name and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                            Text(
                              '\$${plan.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Discount Badge
                      if (plan.discount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan.discount!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Features
                  ...plan.features.take(4).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),

                  if (plan.features.length > 4)
                    Text(
                      '+ ${plan.features.length - 4} more features',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Popular Badge
            if (isPopular)
              Positioned(
                top: -8,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.premiumGold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.mostPopular,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    final selectedPlan = _plans.firstWhere(
          (plan) => plan.id == _selectedPlanId,
      orElse: () => _plans.first,
    );

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected Plan Info
            Text(
              '${selectedPlan.name} - \$${selectedPlan.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                onPressed: () => _subscribe(selectedPlan),
                isLoading: false,
                text: 'Subscribe Now',
                backgroundColor: const Color(AppColors.premiumGold),
              ),
            ),

            const SizedBox(height: 8),

            // Terms
            Text(
              'Terms and conditions apply. Cancel anytime.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _subscribe(SubscriptionPlan plan) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implement actual subscription logic with payment gateway
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscribe'),
        content: Text('Subscribe to ${plan.name} for \$${plan.price.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processSubscription(plan);
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Future<void> _processSubscription(SubscriptionPlan plan) async {
    // TODO: Integrate with actual payment processor
    // For now, simulate successful subscription

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscription to ${plan.name} successful!'),
        backgroundColor: Colors.green,
      ),
    );

    // Update user premium status
    ref.read(authNotifierProvider.notifier).updateSubscriptionStatus(
      isPremium: true,
      premiumExpiresAt: plan.duration != null
          ? DateTime.now().add(Duration(days: plan.duration!))
          : null, // Lifetime
    );

    // Navigate back
    context.pop();
  }

  void _manageSubscription() {
    // TODO: Implement subscription management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Subscription management coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  AuthState get _authState => ref.watch(authNotifierProvider);
}

class _PremiumFeature {
  final IconData icon;
  final String title;
  final String description;

  _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}