library;

import 'package:flutter/material.dart';
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
  ConsumerState<SimplePremiumScreen> createState() => _SimplePremiumScreenState();
}

class _SimplePremiumScreenState extends ConsumerState<SimplePremiumScreen> {
  SubscriptionPlan? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(context.l10n.gymbroPremium),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: subscriptionStatus.when(
          data: (status) => status.isActive
              ? _buildActiveSubscription(context, status)
              : _buildPurchaseView(context),
          loading: () => const Center(child: LoadingIndicator()),
          error: (_, __) => _buildPurchaseView(context),
        ),
      ),
    );
  }

  Widget _buildActiveSubscription(BuildContext context, SubscriptionStatus status) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Active badge
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
                  icon: AppIcons.complete,
                  semanticLabel: 'Active',
                  size: AppIconSize.xxlarge,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.gymbroPremium,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  status.isLifetime
                      ? context.l10n.subscriptionLifetime
                      : status.expirationDate != null
                          ? context.l10n.subscriptionActiveUntil(
                              _formatDate(status.expirationDate!),
                            )
                          : context.l10n.subscriptionLifetime,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manage subscription
          if (status.managementUrl != null)
            TextButton(
              onPressed: () => _openManagementUrl(status.managementUrl!),
              child: Text(context.l10n.manageSubscription),
            ),

          const SizedBox(height: 20),

          // Feature list
          _buildFeatureList(context, theme),
        ],
      ),
    );
  }

  Widget _buildPurchaseView(BuildContext context) {
    final theme = Theme.of(context);
    final plansAsync = ref.watch(availablePlansProvider);
    final actionState = ref.watch(purchaseActionProvider);

    return SingleChildScrollView(
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
                  context.l10n.gymbroPremium,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.selectAPlan,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Plans
          plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return _buildBetaFallback(context, theme);
              }
              return _buildPlansList(context, plans);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: LoadingIndicator(),
            ),
            error: (_, __) => _buildBetaFallback(context, theme),
          ),

          const SizedBox(height: 16),

          // Purchase button
          if (_selectedPlan != null)
            PurchaseButton(
              label: context.l10n.gymbroPremium,
              isLoading: actionState.isPurchasing,
              onPressed: () => _handlePurchase(context),
            ),

          const SizedBox(height: 24),

          // Feature list
          _buildFeatureList(context, theme),

          const SizedBox(height: 16),

          // Restore purchases
          TextButton(
            onPressed: actionState.isPurchasing
                ? null
                : () => _handleRestore(context),
            child: Text(context.l10n.restorePurchases),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<SubscriptionPlan> plans) {
    return Column(
      children: plans.map((plan) {
        final isYearly = plan.period == SubscriptionPeriod.yearly;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlanCard(
            plan: plan,
            isSelected: _selectedPlan?.id == plan.id,
            onTap: () => setState(() => _selectedPlan = plan),
            savingsLabel: isYearly ? context.l10n.savingsPercent : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBetaFallback(BuildContext context, ThemeData theme) {
    return Container(
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
            context.l10n.betaEarlyAdopterTitle,
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
    );
  }

  Widget _buildFeatureList(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.premiumFeatures,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildFeatureItem(
          context,
          AppIcons.history,
          context.l10n.unlimitedHistory,
          context.l10n.unlimitedHistoryDescription,
          theme,
        ),
        _buildFeatureItem(
          context,
          AppIcons.edit,
          context.l10n.editAllWorkouts,
          context.l10n.editAllWorkoutsDescription,
          theme,
        ),
        _buildFeatureItem(
          context,
          AppIcons.block,
          context.l10n.noAds,
          context.l10n.enjoyAdFreeExperience,
          theme,
        ),
      ],
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
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
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
          Icon(AppIcons.complete, color: theme.colorScheme.primary, size: 20),
        ],
      ),
    );
  }

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
        SnackBarService.showError(context, message);
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
        final displayMsg = message == 'noPurchasesToRestore'
            ? context.l10n.noPurchasesToRestore
            : message;
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
