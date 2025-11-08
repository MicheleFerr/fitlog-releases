/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: premium
/// 🔧 Type: screen (tier-1 quality)
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS & Android IAP
/// 
/// Premium subscription screen with tier-1 quality design:
/// - Netflix/Spotify/Apple Fitness+ inspired UI
/// - Glass morphism effects and modern animations
/// - Professional typography and layout
/// - Clear trust signals and social proof
/// - Smooth page transitions with hero animations
library;

import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/premium_upgrade_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/unified_user_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class PremiumPurchaseScreenV2 extends ConsumerStatefulWidget {
  const PremiumPurchaseScreenV2({super.key});

  @override
  ConsumerState<PremiumPurchaseScreenV2> createState() => _PremiumPurchaseScreenV2State();
}

class _PremiumPurchaseScreenV2State extends ConsumerState<PremiumPurchaseScreenV2> 
    with TickerProviderStateMixin {
  
  late AnimationController _heroController;
  late AnimationController _featuresController;
  late AnimationController _pricingController;
  late AnimationController _particlesController;
  late PageController _pageController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _featuresAnimation;
  late Animation<double> _pricingAnimation;
  late Animation<double> _particlesAnimation;
  
  PremiumPlan? _selectedPlan = PremiumPlan.yearly;
  int _currentPage = 0;
  bool _isRestoring = false;
  
  // Product information with dynamic pricing
  static const Map<PremiumPlan, Map<String, String>> _productInfo = {
    PremiumPlan.monthly: {
      'ios_id': 'com.gymbro.premium.monthly',
      'android_id': 'premium_monthly',
      'fallback_price': '\$4.99',
      'period': '/month',
      'save': '',
      'popular': 'false',
    },
    PremiumPlan.yearly: {
      'ios_id': 'com.gymbro.premium.yearly',
      'android_id': 'premium_yearly', 
      'fallback_price': '\$39.99',
      'period': '/year',
      'save': 'Save 33%',
      'popular': 'true',
    },
    PremiumPlan.lifetime: {
      'ios_id': 'com.gymbro.premium.lifetime',
      'android_id': 'premium_lifetime',
      'fallback_price': '\$99.99',
      'period': ' once',
      'save': 'Best Value',
      'popular': 'false',
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pricingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pageController = PageController();

    // Create smooth easing animations
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.elasticOut,
    );
    
    _featuresAnimation = CurvedAnimation(
      parent: _featuresController,
      curve: Curves.decelerate,
    );
    
    _pricingAnimation = CurvedAnimation(
      parent: _pricingController,
      curve: Curves.bounceOut,
    );

    _particlesAnimation = CurvedAnimation(
      parent: _particlesController,
      curve: Curves.linear,
    );
  }

  Future<void> _startAnimationSequence() async {
    // Start particle animation
    _particlesController.repeat();
    
    // Staggered entrance animations
    await _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _featuresController.forward();
    await Future.delayed(const Duration(milliseconds: 200)); 
    await _pricingController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _featuresController.dispose();
    _pricingController.dispose();
    _particlesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    
    final userProfile = ref.watch(unifiedUserProfileProvider);
    final upgradeState = ref.watch(premiumUpgradeProvider);

    // If already premium, show different screen
    if (userProfile.valueOrNull?.isPremium ?? false) {
      return _buildAlreadyPremiumScreen(context, userProfile.valueOrNull!);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Animated background with particles
          _buildAnimatedBackground(context),
          
          // Main content
          PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              // Page 1: Hero & Features
              _buildHeroPage(context),
              // Page 2: Pricing & Purchase
              _buildPricingPage(context, upgradeState),
            ],
          ),

          // Page indicator
          _buildPageIndicator(context),
          
          // Loading overlay
          if (upgradeState.isProcessing || _isRestoring)
            _buildLoadingOverlay(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppIcons.back,
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Glass morphism restore button
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isRestoring ? null : () => _restorePurchases(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.refresh,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Restore',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
            colorScheme.tertiary.withValues(alpha: 0.1),
            colorScheme.surface,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _particlesAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(
              animation: _particlesAnimation.value,
              color: colorScheme.primary,
            ),
            size: size,
          );
        },
      ),
    );
  }

  Widget _buildHeroPage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Animated hero section
            AnimatedBuilder(
              animation: _heroAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_heroAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _heroAnimation.value,
                    child: _buildHeroSection(context),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Features with staggered animation
            AnimatedBuilder(
              animation: _featuresAnimation,
              builder: (context, child) {
                return _buildFeaturesSection(context);
              },
            ),
            
            const SizedBox(height: 40),
            
            // Social proof section
            _buildSocialProofSection(context),
            
            SizedBox(height: 40),
            
            // Continue button
            _buildContinueButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.secondary.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated crown icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.colors.warning,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.warning.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              AppIcons.premium,
              size: 40,
              color: context.colors.surface,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Unlock Your\nFull Potential',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Join thousands of athletes achieving their goals with GymBro Premium',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final features = [
      _FeatureData(
        icon: AppIcons.cloudSyncRounded,
        title: context.l10n.cloudSync,
        description: 'Access your workouts on any device',
        gradient: [colorScheme.primary, colorScheme.secondary],
        delay: 0,
      ),
      _FeatureData(
        icon: AppIcons.backupRounded,
        title: 'Auto Backup',
        description: 'Never lose your progress again',
        gradient: [colorScheme.secondary, colorScheme.tertiary],
        delay: 200,
      ),
      _FeatureData(
        icon: AppIcons.analyticsRounded,
        title: 'Advanced Analytics',
        description: 'Detailed insights & progress tracking',
        gradient: [colorScheme.tertiary, colorScheme.primary],
        delay: 400,
      ),
      _FeatureData(
        icon: AppIcons.peopleRounded,
        title: 'Community Access',
        description: 'Connect with other athletes',
        gradient: [colorScheme.primary, colorScheme.tertiary],
        delay: 600,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.premiumFeatures,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 24),
        ...features.map((feature) => _buildFeatureCard(context, feature)),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureData feature) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + feature.delay),
      tween: Tween(begin: 0.0, end: _featuresAnimation.value),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
                // Glass morphism effect
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  children: [
                    // Gradient icon container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: feature.gradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature.icon,
                        color: context.colors.surface,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Icon(
                      AppIcons.complete,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialProofSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) => 
                Icon(
                  AppIcons.starRounded,
                  color: context.colors.warning,
                  size: 20,
                )
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '4.9/5 from 12,000+ athletes',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '"GymBro Premium changed my entire fitness journey. The analytics help me optimize every workout!"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '— Sarah M., Professional Athlete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.chooseYourPlan,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.colors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  AppIcons.arrowForwardRounded,
                  color: context.colors.surface,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingPage(BuildContext context, PremiumUpgradeState upgradeState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  Text(
                    context.l10n.chooseYourPlan,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Unlock premium features and supercharge your fitness journey',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pricing cards with animation
                  AnimatedBuilder(
                    animation: _pricingAnimation,
                    builder: (context, child) {
                      return _buildPricingCards(context, upgradeState);
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Trust signals
                  _buildTrustSignals(context),
                  
                  const SizedBox(height: 24),
                  
                  // Terms section
                  _buildTermsSection(context),
                ],
              ),
            ),
          ),
          
          // Purchase button (sticky)
          _buildPurchaseButton(context, upgradeState),
        ],
      ),
    );
  }

  Widget _buildPricingCards(BuildContext context, PremiumUpgradeState upgradeState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: PremiumPlan.values.map((plan) {
        final info = _productInfo[plan]!;
        final isSelected = _selectedPlan == plan;
        final isPopular = info['popular'] == 'true';
        final index = PremiumPlan.values.indexOf(plan);

        // Get actual price from store if available
        String displayPrice = info['fallback_price']!;
        if (upgradeState.availableProducts.isNotEmpty) {
          final productId = Platform.isIOS ? info['ios_id'] : info['android_id'];
          final product = upgradeState.availableProducts.cast<ProductDetails?>().firstWhere(
            (p) => p?.id == productId,
            orElse: () => null,
          );
          if (product != null) {
            displayPrice = product.price;
          }
        }

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 200)),
          tween: Tween(begin: 0.0, end: _pricingAnimation.value),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: Opacity(
                opacity: value,
                child: _buildPricingCard(
                  context,
                  plan,
                  info,
                  displayPrice,
                  isSelected,
                  isPopular,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    PremiumPlan plan,
    Map<String, String> info,
    String displayPrice,
    bool isSelected,
    bool isPopular,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedPlan = plan),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSelected 
                  ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ] : null,
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Plan selection indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              width: 2,
                            ),
                            color: isSelected ? colorScheme.primary : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  AppIcons.check,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getPlanTitle(plan),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    displayPrice,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    info['period']!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (plan == PremiumPlan.yearly) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Just \$3.33/month',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (plan == PremiumPlan.yearly) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.secondary],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔥 Most Popular Choice',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Save badge (top right)
                if (_getSaveBadge(plan).isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPopular ? context.colors.warning : colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isPopular ? context.colors.warning : colorScheme.tertiary)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getSaveBadge(plan),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPopular ? context.colors.onSurface : colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustSignals(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            '🛡️ Secure & Trusted',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTrustBadge(
                  context,
                  AppIcons.securityRounded,
                  'Secure Payment',
                  '256-bit SSL',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildTrustBadge(
                  context,
                  AppIcons.cancelRounded,
                  'Easy Cancel',
                  'Anytime',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildTrustBadge(
                  context,
                  AppIcons.privacyTipRounded,
                  'Privacy First',
                  'No tracking',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Subscription Terms',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• Cancel anytime from ${Platform.isIOS ? "App Store" : "Google Play"}\n'
          '• Auto-renewal unless cancelled 24h before period ends\n'
          '• Payment charged to your account after confirmation',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _openUrl('https://gymbro.app/privacy'),
              child: Text(
                context.l10n.privacyPolicy,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () => _openUrl('https://gymbro.app/terms'),
              child: Text(
                context.l10n.termsOfService,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(BuildContext context, PremiumUpgradeState upgradeState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface.withValues(alpha: 0.0),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error message if any
            if (upgradeState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.errorOutlineRounded,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        upgradeState.errorMessage!,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(premiumUpgradeProvider.notifier).clearError(),
                      icon: const Icon(AppIcons.closeRounded),
                      color: colorScheme.onErrorContainer,
                    ),
                  ],
                ),
              ),
            ],

            // Purchase button with gradient
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: upgradeState.isProcessing || _selectedPlan == null
                      ? [
                          colorScheme.outline.withValues(alpha: 0.3),
                          colorScheme.outline.withValues(alpha: 0.2),
                        ]
                      : [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: upgradeState.isProcessing || _selectedPlan == null
                    ? null
                    : [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: upgradeState.isProcessing || _selectedPlan == null
                      ? null
                      : () => _purchasePremium(context),
                  child: Center(
                    child: upgradeState.isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: context.colors.surface,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Processing...',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: context.colors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                AppIcons.rocketLaunchRounded,
                                color: context.colors.surface,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Start Free Trial • ${_getPlanTitle(_selectedPlan)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: context.colors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return ColoredBox(
      color: context.colors.onSurface.withValues(alpha: 0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: context.colors.onSurface.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.surface,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  _isRestoring ? 'Restoring purchases...' : 'Processing payment...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'This may take a few moments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyPremiumScreen(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Premium Status'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation would go here
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  AppIcons.completeOutline,
                  size: 60,
                  color: context.colors.surface,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                context.l10n.yourePremium,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Account: ${profile.accountTier.name.toUpperCase()}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildPremiumFeature(
                      context,
                      context.l10n.cloudSync,
                      'Active',
                      AppIcons.cloudDoneRounded,
                      context.colors.success,
                    ),
                    const Divider(height: 24),
                    _buildPremiumFeature(
                      context,
                      'Auto Backup',
                      'Enabled',
                      AppIcons.backupRounded,
                      context.colors.primary,
                    ),
                    const Divider(height: 24),
                    _buildPremiumFeature(
                      context,
                      'Community Access',
                      'Full Access',
                      AppIcons.peopleRounded,
                      context.colors.secondary,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              TextButton(
                onPressed: () => _openManageSubscription(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.settingsRounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.manageSubscription,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
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

  Widget _buildPremiumFeature(
    BuildContext context,
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          status,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getPlanTitle(PremiumPlan? plan) {
    switch (plan) {
      case PremiumPlan.monthly:
        return context.l10n.monthly;
      case PremiumPlan.yearly:
        return context.l10n.yearly;
      case PremiumPlan.lifetime:
        return context.l10n.lifetime;
      default:
        return '';
    }
  }

  String _getSaveBadge(PremiumPlan plan) {
    switch (plan) {
      case PremiumPlan.yearly:
        return context.l10n.saveThirtyThreePercent;
      case PremiumPlan.lifetime:
        return context.l10n.bestValue;
      default:
        return '';
    }
  }

  Future<void> _purchasePremium(BuildContext context) async {
    if (_selectedPlan == null) return;

    final success = await ref.read(premiumUpgradeProvider.notifier)
        .purchasePremium(_selectedPlan!);

    if (success && mounted) {
      // Purchase initiated, provider handles the flow
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    setState(() => _isRestoring = true);

    try {
      await ref.read(premiumUpgradeProvider.notifier).restorePurchases();

      if (!mounted) return;

      final userProfile = ref.read(unifiedUserProfileProvider).valueOrNull;

      if (!context.mounted) return;

      if (userProfile?.isPremium ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(AppIcons.checkCircle, color: Colors.white),
                SizedBox(width: 8),
                Text('Premium restored successfully!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No purchases found to restore'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  void _openUrl(String url) {
    // Implement URL opening with url_launcher
  }

  void _openManageSubscription() {
    if (Platform.isIOS) {
      _openUrl('https://apps.apple.com/account/subscriptions');
    } else {
      _openUrl('https://play.google.com/store/account/subscriptions');
    }
  }
}

// Helper classes for type safety
class _FeatureData {

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.delay,
  });
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final int delay;
}

// Custom painter for animated background particles
class ParticlesPainter extends CustomPainter {

  ParticlesPainter({
    required this.animation,
    required this.color,
  });
  final double animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Create floating particles effect
    for (int i = 0; i < 20; i++) {
      final double x = (size.width * (i / 20.0)) + 
          (sin(animation * 2 * pi + i) * 50);
      final double y = (size.height * ((i % 4) / 4.0)) + 
          (cos(animation * 2 * pi + i) * 30);
      
      final double radius = 2 + sin(animation * 4 * pi + i) * 1;
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
