library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/effective_premium_access_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/screens/legal_document_screen.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/domain/services/purchase_service.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_action_provider.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/widgets/plan_card.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/widgets/purchase_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
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
  late final PageController _benefitsController;
  SubscriptionPlan? _selectedPlan;
  String? _lastPurchaseViewDebugState;
  int _activeBenefitIndex = 0;

  @override
  void initState() {
    super.initState();
    _benefitsController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _benefitsController.dispose();
    super.dispose();
  }

  Gradient _heroGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        context.colors.primary,
        context.colors.primary.withValues(alpha: 0.78),
        context.colors.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  List<BoxShadow> _heroShadows(BuildContext context) {
    return [
      BoxShadow(
        color: context.colors.shadow.withValues(alpha: 0.16),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  Color _heroForeground(BuildContext context) => context.colors.onPrimary;

  Color _heroOverlay(BuildContext context, {double alpha = 0.18}) {
    return _heroForeground(context).withValues(alpha: alpha);
  }

  @override
  Widget build(BuildContext context) {
    final premiumAccess = ref.watch(effectivePremiumAccessProvider);
    final effectiveStatus = premiumAccess.subscriptionStatus;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: premiumAccess.isActive
          ? _buildActiveView(context, effectiveStatus)
          : ref.watch(subscriptionStatusProvider).isLoading
          ? const Center(child: LoadingIndicator())
          : _buildPurchaseView(context),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMarginHorizontal,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xs),
                _buildActiveHero(context, status),
                const SizedBox(height: AppSpacing.xxl),
                _buildFeatureGrid(context),
                const SizedBox(height: AppSpacing.xl),
                if (status.managementUrl != null)
                  TextButton(
                    onPressed: () => _openManagementUrl(status.managementUrl!),
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
    final heroForeground = _heroForeground(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: _heroGradient(context),
        borderRadius: AppBorderRadius.xlRadius,
        boxShadow: _heroShadows(context),
      ),
      child: Column(
        children: [
          Text(
            context.l10n.gymbroPremium,
            style: context.textTheme.headlineMedium?.copyWith(
              color: heroForeground,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _heroOverlay(context, alpha: 0.16),
              borderRadius: AppBorderRadius.lgRadius,
            ),
            child: Text(
              _buildStatusLabel(context, status),
              style: context.textTheme.bodyMedium?.copyWith(
                color: heroForeground,
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
    final isRevenueCatConfigured = ref.watch(revenueCatConfiguredProvider);
    final hasPlans = plansAsync.value?.isNotEmpty ?? false;
    final bottomInset = context.tabBarInset > 0
        ? context.tabBarInset
        : MediaQuery.of(context).padding.bottom;
    _debugLogPurchaseViewState(plansAsync, isRevenueCatConfigured);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenMarginHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    _buildPurchaseHero(context),
                    const SizedBox(height: 28),

                    // Plans section
                    plansAsync.when(
                      data: (plans) {
                        if (plans.isEmpty) {
                          return isRevenueCatConfigured
                              ? _buildStoreUnavailableFallback(context)
                              : _buildBetaFallback(context);
                        }
                        return Column(
                          children: [
                            _buildPlansList(context, plans),
                            const SizedBox(height: AppSpacing.lg),
                            _buildPurchaseDisclosureCard(context),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: LoadingIndicator(),
                      ),
                      error: (_, __) => isRevenueCatConfigured
                          ? _buildStoreUnavailableFallback(context)
                          : _buildBetaFallback(context),
                    ),

                    const SizedBox(height: 28),

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
                    SizedBox(height: (hasPlans ? 92 : 16) + bottomInset),
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
                AppSpacing.screenMarginHorizontal,
                AppSpacing.sm,
                AppSpacing.screenMarginHorizontal,
                bottomInset + AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PurchaseButton(
                label: _purchaseButtonLabel(context, _selectedPlan!),
                isLoading: actionState.isPurchasing,
                onPressed: () => _handlePurchase(context),
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3, end: 0),
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
    final heroForeground = _heroForeground(context);
    final features = _premiumFeatures(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: _heroGradient(context),
        borderRadius: AppBorderRadius.xlRadius,
        boxShadow: _heroShadows(context),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _benefitsController,
              itemCount: features.length,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() => _activeBenefitIndex = index);
              },
              itemBuilder: (context, index) {
                final feature = features[index];
                return _buildHeroBenefitSlide(context, feature, heroForeground);
              },
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < features.length; i++)
                AnimatedContainer(
                  duration: 200.ms,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == _activeBenefitIndex ? 22 : 8,
                  decoration: BoxDecoration(
                    color: i == _activeBenefitIndex
                        ? heroForeground
                        : heroForeground.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
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
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child:
                PlanCard(
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

  Widget _buildPurchaseDisclosureCard(BuildContext context) {
    final storeTerms = _storeTermsText(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: AppBorderRadius.xlRadius,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.document,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.gymbroPremium,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            storeTerms,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => LegalDocumentScreen.showPrivacyPolicy(context),
                icon: SemanticIcon(
                  icon: AppIcons.privacyTipRounded,
                  semanticLabel: context.l10n.privacyPolicy,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                label: Text(
                  context.l10n.privacyPolicy,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    LegalDocumentScreen.showAppleStandardEula(context),
                icon: SemanticIcon(
                  icon: AppIcons.document,
                  semanticLabel: context.l10n.termsOfUseEula,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                label: Text(
                  context.l10n.termsOfUseEula,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    LegalDocumentScreen.showTermsOfService(context),
                icon: SemanticIcon(
                  icon: AppIcons.document,
                  semanticLabel: context.l10n.serviceTerms,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                label: Text(
                  context.l10n.serviceTerms,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBetaFallback(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.15),
                context.colors.secondary.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppBorderRadius.xlRadius,
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
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.betaEarlyAdopterTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.youHaveAccessToAllFeatures,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.lgRadius,
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
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildStoreUnavailableFallback(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHigh,
            borderRadius: AppBorderRadius.xlRadius,
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
                  icon: AppIcons.warning,
                  semanticLabel: 'Store unavailable',
                  size: AppIconSize.large,
                  color: context.colors.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.gymbroPremium,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.storeNotAvailable,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  // ══════════════════════════════════════════════════════════════════
  // FEATURE GRID (shared between views)
  // ══════════════════════════════════════════════════════════════════

  Widget _buildFeatureGrid(BuildContext context) {
    final features = _premiumFeatures(context);

    return Column(
      children: [
        for (var i = 0; i < features.length; i++)
          _buildFeatureRow(context, features[i], i),
      ],
    );
  }

  List<_FeatureData> _premiumFeatures(BuildContext context) {
    return [
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
        AppIcons.template,
        context.l10n.unlimitedTemplates,
        context.l10n.unlimitedTemplatesDescription,
      ),
    ];
  }

  Widget _buildHeroBenefitSlide(
    BuildContext context,
    _FeatureData feature,
    Color heroForeground,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _heroOverlay(context, alpha: 0.16),
              borderRadius: AppBorderRadius.lgRadius,
            ),
            child: Icon(feature.icon, color: heroForeground, size: 30),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            feature.title,
            style: context.textTheme.headlineSmall?.copyWith(
              color: heroForeground,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            feature.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: heroForeground.withValues(alpha: 0.9),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    _FeatureData feature,
    int index,
  ) {
    return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: AppBorderRadius.smRadius,
                ),
                child: Icon(
                  feature.icon,
                  color: context.colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
                    const SizedBox(height: AppSpacing.xxs),
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
          'premiumActivationFailed' => context.l10n.errorUnexpected,
          PurchaseService.premiumSyncFailedMessage =>
            context.l10n.errorUnexpected,
          'User not authenticated' => context.l10n.errorAuthenticationRequired,
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
        SnackBarService.showSuccess(
          context,
          context.l10n.premiumRestoredSuccess,
        );
      case PurchaseCancelled():
        break;
      case PurchaseError(:final message):
        final displayMsg = switch (message) {
          'noPurchasesToRestore' => context.l10n.noPurchasesToRestore,
          'RevenueCat not configured' => context.l10n.storeNotAvailable,
          'Package not found' => context.l10n.storeNotAvailable,
          'premiumActivationFailed' => context.l10n.errorUnexpected,
          PurchaseService.premiumSyncFailedMessage =>
            context.l10n.errorUnexpected,
          'User not authenticated' => context.l10n.errorAuthenticationRequired,
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

  String _buildStatusLabel(BuildContext context, SubscriptionStatus status) {
    if (status.isLifetime) return context.l10n.subscriptionLifetime;
    if (status.expirationDate != null) {
      return context.l10n.subscriptionActiveUntil(
        _formatDate(status.expirationDate!),
      );
    }
    return context.l10n.premiumMembership;
  }

  String _purchaseButtonLabel(BuildContext context, SubscriptionPlan plan) {
    final productName = context.l10n.gymbroPremium;
    return switch (plan.period) {
      SubscriptionPeriod.monthly => context.l10n.continueWithPremiumMonthlyPlan(
        productName,
      ),
      SubscriptionPeriod.yearly => context.l10n.continueWithPremiumYearlyPlan(
        productName,
      ),
      SubscriptionPeriod.lifetime =>
        context.l10n.continueWithPremiumLifetimePlan(productName),
    };
  }

  String _storeTermsText(BuildContext context) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => context.l10n.cancelAnytimeAppStore,
      _ => context.l10n.cancelAnytimeGooglePlay,
    };
  }

  void _debugLogPurchaseViewState(
    AsyncValue<List<SubscriptionPlan>> plansAsync,
    bool isRevenueCatConfigured,
  ) {
    if (!kDebugMode) return;

    final state = plansAsync.when(
      data: (plans) =>
          'data:${plans.length}:rcConfigured=$isRevenueCatConfigured',
      error: (error, _) => 'error:$error:rcConfigured=$isRevenueCatConfigured',
      loading: () => 'loading:rcConfigured=$isRevenueCatConfigured',
    );

    if (_lastPurchaseViewDebugState == state) return;
    _lastPurchaseViewDebugState = state;

    debugPrint('[SimplePremiumScreen] purchase view state -> $state');

    plansAsync.whenOrNull(
      data: (plans) {
        if (plans.isEmpty) {
          debugPrint(
            '[SimplePremiumScreen] No plans available. '
            'Fallback=${isRevenueCatConfigured ? 'storeUnavailable' : 'beta'}',
          );
        } else {
          debugPrint(
            '[SimplePremiumScreen] Plans shown: '
            '${plans.map((plan) => '${plan.id}/${plan.period.name}@${plan.priceString}').toList()}',
          );
        }
      },
      error: (error, stackTrace) {
        debugPrint(
          '[SimplePremiumScreen] availablePlansProvider error: $error',
        );
      },
    );
  }
}

class _FeatureData {
  const _FeatureData(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}
