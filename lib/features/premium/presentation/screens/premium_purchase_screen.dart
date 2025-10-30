/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: premium
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS & Android IAP
/// 
/// Complete In-App Purchase screen with Apple/Google payments
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/premium_upgrade_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

class PremiumPurchaseScreen extends ConsumerStatefulWidget {
  const PremiumPurchaseScreen({super.key});

  @override
  ConsumerState<PremiumPurchaseScreen> createState() => _PremiumPurchaseScreenState();
}

class _PremiumPurchaseScreenState extends ConsumerState<PremiumPurchaseScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _shimmerController;
  PremiumPlan? _selectedPlan;
  bool _isRestoring = false;
  
  // Product IDs (must match App Store Connect & Google Play Console)
  static const Map<PremiumPlan, Map<String, String>> productInfo = {
    PremiumPlan.monthly: {
      'ios_id': 'com.gymbro.premium.monthly',
      'android_id': 'premium_monthly',
      'price': '\$4.99/month',
      'save': '',
    },
    PremiumPlan.yearly: {
      'ios_id': 'com.gymbro.premium.yearly', 
      'android_id': 'premium_yearly',
      'price': '\$39.99/year',
      'save': 'Save 33%',
    },
    PremiumPlan.lifetime: {
      'ios_id': 'com.gymbro.premium.lifetime',
      'android_id': 'premium_lifetime', 
      'price': '\$99.99 once',
      'save': 'Best Value',
    },
  };
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Default to yearly plan (best value)
    _selectedPlan = PremiumPlan.yearly;
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final userProfile = ref.watch(userProfileProvider);
    final upgradeState = ref.watch(premiumUpgradeProvider);
    
    // Check if already premium
    if (userProfile.valueOrNull?.isPremium ?? false) {
      return _buildAlreadyPremiumScreen(context, userProfile.valueOrNull!);
    }
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.goPremium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Restore purchases button
          TextButton(
            onPressed: _isRestoring ? null : () => _restorePurchases(context),
            child: Text(
              l10n.restorePurchases,
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero section
                        _buildHeroSection(context),
                        const SizedBox(height: 24),
                        
                        // Features grid
                        _buildFeaturesGrid(context),
                        const SizedBox(height: 32),
                        
                        // Pricing plans
                        _buildPricingPlans(context, upgradeState),
                        const SizedBox(height: 24),
                        
                        // Terms
                        _buildTermsSection(context),
                      ],
                    ),
                  ),
                ),
                
                // Purchase button (sticky bottom)
                _buildPurchaseButton(context, upgradeState),
              ],
            ),
          ),
          
          // Loading overlay
          if (upgradeState.isProcessing || _isRestoring)
            _buildLoadingOverlay(context),
        ],
      ),
    );
  }
  
  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.star, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Unlock GymBro Premium',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sync everywhere • Backup forever • Join the community',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final features = [
      ('☁️', 'Cloud Sync', 'All devices, always in sync'),
      ('💾', 'Auto Backup', 'Never lose your data'),
      ('👥', 'Community', 'Share & discover workouts'),
      ('📊', 'Analytics Pro', 'Advanced insights'),
      ('⚡', 'Live Updates', 'Real-time sync'),
      ('🎯', 'Priority Support', 'Get help fast'),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final (emoji, title, subtitle) = features[index];
        return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPricingPlans(BuildContext context, PremiumUpgradeState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Plan cards
        ...PremiumPlan.values.map((plan) {
          final info = productInfo[plan]!;
          final isSelected = _selectedPlan == plan;
          final isRecommended = plan == PremiumPlan.yearly;
          
          // Get actual price from store if available
          String displayPrice = info['price']!;
          if (state.availableProducts.isNotEmpty) {
            final productId = Platform.isIOS ? info['ios_id'] : info['android_id'];
            final product = state.availableProducts.firstWhere(
              (p) => p.id == productId,
              orElse: () => state.availableProducts.first,
            );
            displayPrice = product.price;
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedPlan = plan),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected 
                      ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                      : null,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Radio button
                          Radio<PremiumPlan>(
                            value: plan,
                            groupValue: _selectedPlan,
                            onChanged: (value) => setState(() => _selectedPlan = value),
                            activeColor: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          
                          // Plan details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getPlanTitle(plan),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayPrice,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (plan == PremiumPlan.yearly)
                                  Text(
                                    'Only \$3.33/month',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Save badge
                          if (info['save']!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isRecommended 
                                    ? colorScheme.primary
                                    : colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                info['save']!,
                                style: TextStyle(
                                  color: isRecommended
                                      ? colorScheme.onPrimary
                                      : colorScheme.onTertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Recommended badge
                    if (isRecommended)
                      Positioned(
                        top: 0,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildTermsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Terms & Conditions',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '• Cancel anytime from ${Platform.isIOS ? "App Store" : "Google Play"}\n'
          '• Subscription auto-renews unless turned off\n'
          '• Payment charged to ${Platform.isIOS ? "iTunes" : "Google Play"} account',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _showLegalDocument(context, 'privacy'),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
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
              onPressed: () => _showLegalDocument(context, 'terms'),
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPurchaseButton(BuildContext context, PremiumUpgradeState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error message if any
            if (state.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(premiumUpgradeProvider.notifier).clearError(),
                      icon: const Icon(Icons.close),
                      color: colorScheme.onErrorContainer,
                    ),
                  ],
                ),
              ),
            
            // Purchase button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: state.isProcessing || _selectedPlan == null
                    ? null
                    : () => _purchasePremium(context),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  state.isProcessing
                      ? 'Processing...'
                      : 'Continue with ${_getPlanTitle(_selectedPlan)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _isRestoring ? 'Restoring purchases...' : 'Processing payment...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      appBar: AppBar(
        title: const Text('Premium Status'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'You\'re Premium!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Account tier: ${profile.accountTier.name.toUpperCase()}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatusRow(
                        context,
                        'Cloud Sync',
                        'Active',
                        Icons.cloud_done,
                        Colors.green,
                      ),
                      const Divider(),
                      _buildStatusRow(
                        context,
                        'Backup',
                        'Automatic',
                        Icons.backup,
                        Colors.green,
                      ),
                      const Divider(),
                      _buildStatusRow(
                        context,
                        'Community',
                        'Full Access',
                        Icons.people,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => _openManageSubscription(),
                child: Text(
                  'Manage Subscription',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(
    BuildContext context,
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            status,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPlanTitle(PremiumPlan? plan) {
    switch (plan) {
      case PremiumPlan.monthly:
        return 'Monthly';
      case PremiumPlan.yearly:
        return 'Yearly';
      case PremiumPlan.lifetime:
        return 'Lifetime';
      default:
        return '';
    }
  }
  
  Future<void> _purchasePremium(BuildContext context) async {
    if (_selectedPlan == null) return;
    
    final success = await ref.read(premiumUpgradeProvider.notifier)
        .purchasePremium(_selectedPlan!);
    
    if (success && mounted) {
      // Purchase initiated, wait for result via state updates
      // The provider will handle the actual purchase flow
    }
  }
  
  Future<void> _restorePurchases(BuildContext context) async {
    setState(() => _isRestoring = true);
    
    try {
      await ref.read(premiumUpgradeProvider.notifier).restorePurchases();
      
      if (mounted) {
        final userProfile = ref.read(userProfileProvider).valueOrNull;
        if (userProfile?.isPremium ?? false) {
          // Successfully restored
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Premium restored successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          // No purchases to restore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No purchases found to restore'),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }
  
  void _openUrl(String url) {
    // Implement URL opening
    // You can use url_launcher package
  }
  
  void _openManageSubscription() {
    if (Platform.isIOS) {
      _openUrl('https://apps.apple.com/account/subscriptions');
    } else {
      _openUrl('https://play.google.com/store/account/subscriptions');
    }
  }
  
  void _showLegalDocument(BuildContext context, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LegalDocumentScreen(documentType: type),
      ),
    );
  }
}

// Premium upgrade provider reference
final premiumUpgradeProvider = StateNotifierProvider<PremiumUpgradeNotifier, PremiumUpgradeState>((ref) {
  return PremiumUpgradeNotifier(ref);
});