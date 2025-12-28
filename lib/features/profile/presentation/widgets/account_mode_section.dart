/// Account Mode Section Widget
///
/// Displays the current account mode and allows switching between:
/// - Solo: Independent training
/// - Coach: Managing athletes
/// - Coached: Training with a coach
///
/// **Layer**: Presentation
/// **Feature**: Profile
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/account_mode.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Section displaying account mode with actions
///
/// Shows:
/// - Current mode indicator (Solo/Coach/Coached)
/// - Mode-specific quick actions
/// - Switch mode options
class AccountModeSection extends ConsumerWidget {
  const AccountModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(accountModeProvider);
    final myCoach = ref.watch(myCoachProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with mode indicator
            _ModeHeader(currentMode: currentMode, coachName: myCoach?.coachName),

            // Divider
            Divider(
              height: 1,
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
            ),

            // Mode-specific actions
            _ModeActions(currentMode: currentMode),
          ],
        ),
      ),
    );
  }
}

/// Header showing current mode
class _ModeHeader extends StatelessWidget {
  const _ModeHeader({
    required this.currentMode,
    this.coachName,
  });

  final AccountMode currentMode;
  final String? coachName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Mode icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getModeColor(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getModeIcon(),
              color: _getModeColor(context),
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Mode info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getModeLabel(context),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (currentMode.isCoached && coachName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.linkedToCoach(coachName!),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Mode chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: _getModeColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getModeColor(context).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getModeChipLabel(context),
              style: context.textTheme.labelSmall?.copyWith(
                color: _getModeColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon() {
    return switch (currentMode) {
      AccountMode.solo => AppIcons.person,
      AccountMode.coach => AppIcons.school,
      AccountMode.coached => AppIcons.fitnessCenter,
    };
  }

  Color _getModeColor(BuildContext context) {
    return switch (currentMode) {
      AccountMode.solo => context.colors.primary,
      AccountMode.coach => context.colors.tertiary,
      AccountMode.coached => context.colors.secondary,
    };
  }

  String _getModeLabel(BuildContext context) {
    return switch (currentMode) {
      AccountMode.solo => context.l10n.accountModeSolo,
      AccountMode.coach => context.l10n.accountModeCoach,
      AccountMode.coached => context.l10n.accountModeCoached,
    };
  }

  String _getModeChipLabel(BuildContext context) {
    return switch (currentMode) {
      AccountMode.solo => context.l10n.accountModeSolo,
      AccountMode.coach => context.l10n.accountModeCoach,
      AccountMode.coached => context.l10n.accountModeCoached,
    };
  }
}

/// Mode-specific action buttons
class _ModeActions extends ConsumerWidget {
  const _ModeActions({required this.currentMode});

  final AccountMode currentMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: switch (currentMode) {
        AccountMode.solo => _buildSoloActions(context, ref),
        AccountMode.coach => _buildCoachActions(context, ref),
        AccountMode.coached => _buildCoachedActions(context, ref),
      },
    );
  }

  /// Solo mode: Show options to become coach or find a coach
  Widget _buildSoloActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Become a Coach
        Expanded(
          child: _ActionButton(
            icon: AppIcons.school,
            label: context.l10n.becomeCoach,
            color: context.colors.tertiary,
            onTap: () => _enableCoachMode(context, ref),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Find a Coach
        Expanded(
          child: _ActionButton(
            icon: AppIcons.search,
            label: context.l10n.findCoach,
            color: context.colors.secondary,
            onTap: () => context.pushNamed(AppRoutes.linkCoachName),
          ),
        ),
      ],
    );
  }

  /// Coach mode: Show manage athletes and switch back
  Widget _buildCoachActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Manage Athletes
        Expanded(
          flex: 2,
          child: _ActionButton(
            icon: AppIcons.people,
            label: context.l10n.manageAthletes,
            color: context.colors.tertiary,
            filled: true,
            onTap: () => context.pushNamed(AppRoutes.coachDashboardName),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Switch to Personal
        Expanded(
          child: _ActionButton(
            icon: AppIcons.person,
            label: context.l10n.switchToPersonal,
            color: context.colors.outline,
            onTap: () => _switchToSolo(context, ref),
          ),
        ),
      ],
    );
  }

  /// Coached mode: Show view coach and switch back
  Widget _buildCoachedActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // View Coach (placeholder for now)
        Expanded(
          flex: 2,
          child: _ActionButton(
            icon: AppIcons.fitnessCenter,
            label: context.l10n.viewCoach,
            color: context.colors.secondary,
            filled: true,
            onTap: () {
              // TODO: Show coach info modal
              SnackBarService.showInfo(context, 'Coming soon!');
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Switch to Personal
        Expanded(
          child: _ActionButton(
            icon: AppIcons.person,
            label: context.l10n.switchToPersonal,
            color: context.colors.outline,
            onTap: () => _switchToSolo(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _enableCoachMode(BuildContext context, WidgetRef ref) async {
    await HapticFeedback.mediumImpact();

    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmSwitchMode),
        content: Text(context.l10n.confirmSwitchModeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.becomeCoach),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Enable coach mode
    final code = await ref
        .read(accountModeNotifierProvider.notifier)
        .enableCoachMode();

    if (code != null && context.mounted) {
      SnackBarService.showSuccess(context, context.l10n.coachModeEnabled);
      // Navigate to coach dashboard
      await context.pushNamed<void>(AppRoutes.coachDashboardName);
    }
  }

  Future<void> _switchToSolo(BuildContext context, WidgetRef ref) async {
    await HapticFeedback.lightImpact();

    await ref.read(accountModeNotifierProvider.notifier).resetToSoloMode();

    if (context.mounted) {
      SnackBarService.showInfo(context, context.l10n.soloModeEnabled);
    }
  }
}

/// Reusable action button
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled ? context.colors.onPrimary : color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: filled ? context.colors.onPrimary : color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
