import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Simple premium screen that works without crashes
class SimplePremiumScreen extends ConsumerWidget {
  const SimplePremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumUserProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(context.l10n.gymbroPremium),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SemanticIcon(
  icon: AppIcons.star,
  semanticLabel: 'Star',
  size: AppIconSize.medium,
  color: theme.colorScheme.onPrimary,
),
                    const SizedBox(height: 16),
                    Text(
                      isPremium ? context.l10n.youArePremium : context.l10n.unlockPremium,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                        ? context.l10n.enjoyAllPremiumFeatures
                        : context.l10n.getUnlimitedAccess,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Features List
              Text(
                context.l10n.premiumFeatures,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildFeatureItem(
                context,
                AppIcons.analytics,
                context.l10n.volumeProgress,
                context.l10n.trackWorkoutVolume,
                theme,
              ),
              _buildFeatureItem(
                context,
                AppIcons.dashboard,
                context.l10n.weeklyDashboard,
                context.l10n.comprehensiveWeeklyAnalytics,
                theme,
              ),
              _buildFeatureItem(
                context,
                AppIcons.balance,
                context.l10n.muscleBalance,
                context.l10n.analyzeMuscleGroupBalance,
                theme,
              ),
              _buildFeatureItem(
                context,
                AppIcons.insights,
                context.l10n.advancedAnalytics,
                context.l10n.deepInsights,
                theme,
              ),
              _buildFeatureItem(
                context,
                AppIcons.history,
                context.l10n.detailedHistory,
                context.l10n.completeWorkoutHistory,
                theme,
              ),
              _buildFeatureItem(
                context,
                AppIcons.cloudSync,
                context.l10n.cloudSync,
                context.l10n.syncAcrossDevices,
                theme,
              ),
              _buildFeatureItem(
                context,
                AppIcons.block,
                context.l10n.noAds,
                context.l10n.enjoyAdFreeExperience,
                theme,
              ),
              
              const SizedBox(height: 30),
              
              // Pricing Section
              if (!isPremium) ...[
                Text(
                  context.l10n.chooseYourPlan,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Monthly Plan
                _buildPricingCard(
                  context,
                  context.l10n.monthly,
                  '€4.99',
                  '/month',
                  false,
                  theme,
                ),
                const SizedBox(height: 12),

                // Yearly Plan - Best Value
                _buildPricingCard(
                  context,
                  context.l10n.yearly,
                  '€39.99',
                  '/year',
                  true,
                  theme,
                ),
                const SizedBox(height: 12),

                // Lifetime Plan
                _buildPricingCard(
                  context,
                  context.l10n.lifetime,
                  '€99.99',
                  'one time',
                  false,
                  theme,
                ),
                
                const SizedBox(height: 30),
                
                // Coming Soon Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.info,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.inAppPurchasesComingSoon,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Already Premium
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SemanticIcon(
  icon: AppIcons.complete,
  semanticLabel: 'Complete',
  size: AppIconSize.xxlarge,
  color: theme.colorScheme.primary,
),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.thankYouForBeingPremium,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.youHaveAccessToAllFeatures,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.complete,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPricingCard(
    BuildContext context,
    String title,
    String price,
    String period,
    bool isPopular,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.planWillBeAvailableSoon(title)),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular 
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.bestValue,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (title == context.l10n.yearly)
                    Text(
                      context.l10n.saveVsMonthly,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPopular 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  period,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
