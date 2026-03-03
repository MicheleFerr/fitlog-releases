library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_action_provider.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/widgets/plan_card.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/widgets/purchase_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class SimplePremiumScreen extends ConsumerStatefulWidget {
  const SimplePremiumScreen({super.key});

  @override
  ConsumerState<SimplePremiumScreen> createState() =>
      _SimplePremiumScreenState();
}

class _SimplePremiumScreenState extends ConsumerState<SimplePremiumScreen> {
  SubscriptionPlan? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: subscriptionStatus.when(
        data: (status) => status.isActive
            ? _buildActiveView(context, status)
            : _buildPurchaseView(context),
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => _buildPurchaseView(context),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ACTIVE SUBSCRIPTION VIEW
  // ══════════════════════════════════════════════════════════════════

  Widget _buildActiveView(BuildContext context, SubscriptionStatus status) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildActiveHero(context, status),
                const SizedBox(height: 32),
                _buildFeatureGrid(context),
                const SizedBox(height: 24),
                if (status.managementUrl != null)
                  TextButton(
                    onPressed: () =>
                        _openManagementUrl(status.managementUrl!),
                    child: Text(context.l10n.manageSubscription),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveHero(BuildContext context, SubscriptionStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.7),
            context.colors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const SemanticIcon(
              icon: AppIcons.diamond,
              semanticLabel: 'Premium',
              size: AppIconSize.xlarge,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.gymbroPremium,
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.isLifetime
                  ? context.l10n.subscriptionLifetime
                  : status.expirationDate != null
                      ? context.l10n.subscriptionActiveUntil(
                          _formatDate(status.expirationDate!),
                        )
                      : context.l10n.subscriptionLifetime,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  // ══════════════════════════════════════════════════════════════════
  // PURCHASE VIEW
  // ══════════════════════════════════════════════════════════════════

  Widget _buildPurchaseView(BuildContext context) {
    final plansAsync = ref.watch(availablePlansProvider);
    final actionState = ref.watch(purchaseActionProvider);
    final hasPlans = plansAsync.value?.isNotEmpty ?? false;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildPurchaseHero(context),
                    const SizedBox(height: 28),

                    // Plans section
                    plansAsync.when(
                      data: (plans) {
                        if (plans.isEmpty) return _buildBetaFallback(context);
                        return _buildPlansList(context, plans);
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: LoadingIndicator(),
                      ),
                      error: (_, __) => _buildBetaFallback(context),
                    ),

                    const SizedBox(height: 28),

                    // Feature grid
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.l10n.everythingInFree,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureGrid(context),

                    const SizedBox(height: 24),

                    // Social proof
                    Text(
                      context.l10n.joinThousandsOfAthletes,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Restore purchases
                    TextButton(
                      onPressed: actionState.isPurchasing
                          ? null
                          : () => _handleRestore(context),
                      child: Text(context.l10n.restorePurchases),
                    ),

                    // Extra bottom padding for sticky button + tab bar
                    SizedBox(
                      height: (hasPlans ? 100 : 16) +
                          MediaQuery.of(context).padding.bottom +
                          kBottomNavigationBarHeight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Sticky bottom CTA
        if (_selectedPlan != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight +
                    12,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PurchaseButton(
                label: context.l10n.continueWithPremium,
                isLoading: actionState.isPurchasing,
                onPressed: () => _handlePurchase(context),
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .slideY(begin: 0.3, end: 0),
          ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text(context.l10n.gymbroPremium),
      centerTitle: true,
      floating: true,
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildPurchaseHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.7),
            context.colors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const SemanticIcon(
              icon: AppIcons.diamond,
              semanticLabel: 'Premium',
              size: AppIconSize.large,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          const SizedBox(height: 20),
          Text(
            context.l10n.unlockYourFullPotential,
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            context.l10n.premiumHeroSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildPlansList(BuildContext context, List<SubscriptionPlan> plans) {
    return Column(
      children: [
        for (var i = 0; i < plans.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlanCard(
              plan: plans[i],
              isSelected: _selectedPlan?.id == plans[i].id,
              onTap: () => setState(() => _selectedPlan = plans[i]),
              savingsLabel: plans[i].period == SubscriptionPeriod.yearly
                  ? context.l10n.savingsPercent
                  : null,
            )
                .animate()
                .fadeIn(delay: (400 + i * 100).ms, duration: 300.ms)
                .slideX(begin: 0.05, end: 0),
          ),
      ],
    );
  }

  Widget _buildBetaFallback(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.15),
            context.colors.secondary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: SemanticIcon(
              icon: AppIcons.celebration,
              semanticLabel: 'Celebration',
              size: AppIconSize.large,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.betaEarlyAdopterTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.youHaveAccessToAllFeatures,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.l10n.allFeaturesFreeInBeta,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }

  // ══════════════════════════════════════════════════════════════════
  // FEATURE GRID (shared between views)
  // ══════════════════════════════════════════════════════════════════

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureData(
        AppIcons.history,
        context.l10n.unlimitedHistory,
        context.l10n.unlimitedHistoryDescription,
      ),
      _FeatureData(
        AppIcons.block,
        context.l10n.noAds,
        context.l10n.enjoyAdFreeExperience,
      ),
      _FeatureData(
        AppIcons.analytics,
        context.l10n.premiumAdvancedAnalytics,
        context.l10n.premiumAdvancedAnalyticsDesc,
      ),
      _FeatureData(
        AppIcons.ai,
        context.l10n.premiumAiCoachUnlimited,
        context.l10n.premiumAiCoachUnlimitedDesc,
      ),
      _FeatureData(
        AppIcons.cloudSync,
        context.l10n.premiumCloudBackup,
        context.l10n.premiumCloudBackupDesc,
      ),
      _FeatureData(
        AppIcons.edit,
        context.l10n.editAllWorkouts,
        context.l10n.editAllWorkoutsDescription,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < features.length; i++)
          _buildFeatureRow(context, features[i], i),
      ],
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    _FeatureData feature,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              feature.icon,
              color: context.colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SemanticIcon(
            icon: AppIcons.complete,
            semanticLabel: 'Included',
            size: AppIconSize.small,
            color: context.colors.primary,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (500 + index * 80).ms, duration: 300.ms)
        .slideX(begin: 0.03, end: 0);
  }

  // ══════════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════════

  Future<void> _handlePurchase(BuildContext context) async {
    if (_selectedPlan == null) return;

    final result = await ref
        .read(purchaseActionProvider.notifier)
        .purchase(_selectedPlan!);

    if (!context.mounted) return;

    switch (result) {
      case PurchaseSuccess():
        SnackBarService.showSuccess(context, context.l10n.purchaseSuccessful);
      case PurchaseCancelled():
        break;
      case PurchaseError(:final message):
        final displayMsg = switch (message) {
          'RevenueCat not configured' => context.l10n.storeNotAvailable,
          'Package not found' => context.l10n.storeNotAvailable,
          _ => message,
        };
        SnackBarService.showError(context, displayMsg);
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    final result = await ref.read(purchaseActionProvider.notifier).restore();

    if (!context.mounted) return;

    switch (result) {
      case PurchaseSuccess():
        SnackBarService.showSuccess(context, context.l10n.purchaseSuccessful);
      case PurchaseCancelled():
        break;
      case PurchaseError(:final message):
        final displayMsg = switch (message) {
          'noPurchasesToRestore' => context.l10n.noPurchasesToRestore,
          'RevenueCat not configured' => context.l10n.storeNotAvailable,
          'Package not found' => context.l10n.storeNotAvailable,
          _ => message,
        };
        SnackBarService.showError(context, displayMsg);
    }
  }

  Future<void> _openManagementUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FeatureData {
  const _FeatureData(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}
