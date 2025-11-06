/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: premium
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal with iOS/Android payment
/// 
/// Premium upgrade screen with smart refresh
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/premium_upgrade_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/account_tier.dart';

class PremiumUpgradeScreen extends ConsumerStatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  ConsumerState<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends ConsumerState<PremiumUpgradeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _pendingRefreshTimer;
  bool _isProcessingUpgrade = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pendingRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    
    final user = ref.watch(currentUserProvider).value;
    final isPremium = user?.accountTier == AccountTier.premium || 
                      user?.accountTier == AccountTier.pro;
    
    if (isPremium) {
      // Already premium
      return _buildAlreadyPremiumScreen(context);
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    l10n.goPremium,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Section
                    _buildHeroSection(context),
                    const SizedBox(height: 32),
                    
                    // Features List
                    _buildFeaturesSection(context),
                    const SizedBox(height: 32),
                    
                    // Pricing Plans
                    _buildPricingSection(context),
                    const SizedBox(height: 32),
                    
                    // Testimonials
                    _buildTestimonialsSection(context),
                    const SizedBox(height: 32),
                    
                    // FAQ
                    _buildFAQSection(context),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      // Sticky Bottom Button
      bottomSheet: _buildBottomPurchaseButton(context),
    );
  }
  
  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.rocket_launch,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock Your Full Potential',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sync across all devices, access community features, and never lose your progress',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeaturesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final features = [
      (Icons.cloud_sync, 'Cross-Device Sync', 'Access your workouts on any device'),
      (Icons.backup, 'Cloud Backup', 'Never lose your data with automatic backups'),
      (Icons.people, 'Community Access', 'Share and discover workout templates'),
      (Icons.speed, 'Priority Sync', 'Real-time updates every 5 minutes'),
      (Icons.trending_up, 'Advanced Analytics', 'Deep insights into your progress'),
      (Icons.support_agent, 'Priority Support', 'Get help when you need it'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                feature.$1,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(feature.$2),
            subtitle: Text(feature.$3),
            trailing: Icon(
              Icons.check_circle,
              color: colorScheme.primary,
            ),
          ),
        )),
      ],
    );
  }
  
  Widget _buildPricingSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // Monthly Plan
        _buildPricingCard(
          context,
          title: 'Monthly',
          price: '\$4.99',
          period: '/month',
          isPopular: false,
          onTap: () => _handlePurchase(context, 'monthly'),
        ),
        const SizedBox(height: 12),
        // Annual Plan
        _buildPricingCard(
          context,
          title: 'Annual',
          price: '\$39.99',
          period: '/year',
          savings: 'Save 33%',
          isPopular: true,
          onTap: () => _handlePurchase(context, 'annual'),
        ),
        const SizedBox(height: 12),
        // Lifetime Plan
        _buildPricingCard(
          context,
          title: 'Lifetime',
          price: '\$99.99',
          period: 'one time',
          savings: 'Best Value',
          isPopular: false,
          onTap: () => _handlePurchase(context, 'lifetime'),
        ),
      ],
    );
  }
  
  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? savings,
    bool isPopular = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isPopular ? colorScheme.primary : colorScheme.outline,
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isPopular 
              ? colorScheme.primaryContainer.withValues(alpha: 0.1)
              : colorScheme.surface,
        ),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'POPULAR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge,
                        ),
                        if (savings != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              savings,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        period,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestimonialsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final testimonials = [
      ('John D.', '⭐⭐⭐⭐⭐', 'The sync feature is a game changer! I can start a workout on my phone and finish on my tablet.'),
      ('Sarah M.', '⭐⭐⭐⭐⭐', 'Community templates saved me hours of planning. Worth every penny!'),
      ('Mike R.', '⭐⭐⭐⭐⭐', 'Never lost a workout since going premium. The backup is automatic and reliable.'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Users Say',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                testimonial.$1[0],
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              testimonial.$1,
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              testimonial.$2,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          testimonial.$3,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildFAQSection(BuildContext context) {
    final theme = Theme.of(context);
    
    final faqs = [
      ('Can I cancel anytime?', 'Yes! You can cancel your subscription anytime from settings.'),
      ('What happens to my data if I cancel?', 'Your data remains safe locally. You just lose cloud sync.'),
      ('Can I change plans?', 'Yes, you can upgrade or downgrade anytime.'),
      ('Is my payment secure?', 'Yes, we use Apple/Google payment systems for maximum security.'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...faqs.map((faq) => ExpansionTile(
          title: Text(faq.$1),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(faq.$2),
            ),
          ],
        )),
      ],
    );
  }
  
  Widget _buildBottomPurchaseButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: _isProcessingUpgrade 
                  ? null 
                  : () => _handlePurchase(context, 'annual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _isProcessingUpgrade
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch),
                        const SizedBox(width: 8),
                        Text(
                          'Start Free Trial - Then \$39.99/year',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
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
  
  Widget _buildAlreadyPremiumScreen(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Membership'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'You\'re Premium!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for supporting GymBro',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.accountTier.name.toUpperCase() ?? 'PREMIUM',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to subscription management
                },
                icon: const Icon(Icons.settings),
                label: const Text('Manage Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _handlePurchase(BuildContext context, String plan) async {
    setState(() {
      _isProcessingUpgrade = true;
    });
    
    // Cancel any pending refresh timer
    _pendingRefreshTimer?.cancel();
    
    // Start a 2-minute timer that will refresh profile even if purchase fails
    // This handles the case where user starts purchase but doesn't complete
    _pendingRefreshTimer = Timer(const Duration(minutes: 2), () async {
      debugPrint('⏰ 2-minute timer triggered - refreshing profile...');
      await ref.read(currentUserProvider.notifier).forceRefreshProfile();
    });
    
    try {
      // Call the purchase provider
      final success = await ref.read(premiumUpgradeProvider.notifier)
          .purchasePremium(plan);
      
      if (success) {
        // Purchase successful! Cancel the 2-minute timer
        _pendingRefreshTimer?.cancel();
        
        // Immediately refresh profile
        debugPrint('✅ Purchase successful - refreshing profile immediately');
        await ref.read(currentUserProvider.notifier).forceRefreshProfile();
        
        // Show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Welcome to Premium! 🎉'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigate back or to premium features
          Navigator.of(context).pop(true);
        }
      } else {
        // Purchase cancelled or failed
        debugPrint('❌ Purchase cancelled/failed - 2-minute timer still active');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase cancelled'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingUpgrade = false;
        });
      }
    }
  }
}