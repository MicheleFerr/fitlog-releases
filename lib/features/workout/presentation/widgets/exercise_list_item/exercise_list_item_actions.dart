import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Configuration for which actions to show in the popup menu
class ExerciseListItemActionsConfig {
  const ExerciseListItemActionsConfig({
    this.showAdvancedMenu = false,
    this.showCommunitySuggestions = false,
    this.showExerciseInsights = false,
  });

  /// Creates config from AppConfig values with Pro mode defaults
  factory ExerciseListItemActionsConfig.fromAppConfig({
    bool? showAdvanced,
    bool? showCommunity,
    bool? showInsights,
    required bool isProMode,
  }) {
    return ExerciseListItemActionsConfig(
      showAdvancedMenu: showAdvanced ?? isProMode,
      showCommunitySuggestions: showCommunity ?? isProMode,
      showExerciseInsights: showInsights ?? isProMode,
    );
  }

  final bool showAdvancedMenu;
  final bool showCommunitySuggestions;
  final bool showExerciseInsights;
}

/// Popup menu actions for ExerciseListItem
///
/// Provides auto adjustment, edit, replace, duplicate, delete, insights,
/// and community advice actions via a PopupMenuButton.
///
/// Extracted from exercise_list_item.dart for Single Responsibility.
class ExerciseListItemActions extends StatelessWidget {
  const ExerciseListItemActions({
    super.key,
    required this.exercise,
    required this.config,
    required this.onAutoAdjustment,
    required this.onEdit,
    required this.onChangeExercise,
    required this.onDuplicate,
    required this.onDelete,
    this.onInsight,
    this.onCommunityAdvice,
  });

  final Exercise exercise;
  final ExerciseListItemActionsConfig config;
  final VoidCallback onAutoAdjustment;
  final VoidCallback onEdit;
  final VoidCallback onChangeExercise;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback? onInsight;
  final VoidCallback? onCommunityAdvice;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleSelection(value, context),
      itemBuilder: (context) => _buildMenuItems(context),
    );
  }

  void _handleSelection(String value, BuildContext context) {
    HapticFeedback.selectionClick();

    switch (value) {
      case 'auto_adjustment':
        onAutoAdjustment();
        break;
      case 'edit':
        onEdit();
        break;
      case 'change_exercise':
        onChangeExercise();
        break;
      case 'duplicate':
        onDuplicate();
        break;
      case 'delete':
        onDelete();
        break;
      case 'insight':
        onInsight?.call();
        break;
      case 'community_advice':
        onCommunityAdvice?.call();
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    return [
      // Auto Adjustment - always shown
      _buildAutoAdjustmentItem(context),
      const PopupMenuDivider(),

      // Delete - always shown
      _buildDeleteItem(context),

      // Advanced options - conditional
      if (config.showAdvancedMenu) ...[
        const PopupMenuDivider(),
        _buildEditItem(context),
        _buildChangeExerciseItem(context),
        _buildDuplicateItem(context),
      ],

      // Insights - conditional
      if (config.showExerciseInsights && config.showAdvancedMenu)
        _buildInsightItem(context),

      // Community advice - conditional
      if (config.showCommunitySuggestions && config.showAdvancedMenu)
        _buildCommunityAdviceItem(context),
    ];
  }

  PopupMenuItem<String> _buildAutoAdjustmentItem(BuildContext context) {
    final hasAutoAdjustment = exercise.autoAdjustmentType != null;

    return PopupMenuItem(
      value: 'auto_adjustment',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.autoAwesome,
            semanticLabel: context.l10n.autoAdjustment,
            size: AppIconSize.small,
            color: hasAutoAdjustment ? context.colors.primary : null,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.autoAdjustment,
            style: hasAutoAdjustment
                ? context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  )
                : null,
          ),
          if (hasAutoAdjustment) ...[
            const Spacer(),
            _buildAutoAdjustmentBadge(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoAdjustmentBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        exercise.autoAdjustmentType == AutoAdjustmentType.apre ? 'APRE' : 'RPE',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildDeleteItem(BuildContext context) {
    return PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.delete,
            semanticLabel: context.l10n.delete,
            size: AppIconSize.small,
            color: context.colors.error,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.delete,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildEditItem(BuildContext context) {
    return PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.edit,
            semanticLabel: context.l10n.exerciseListEdit,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Text(context.l10n.exerciseListEdit),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildChangeExerciseItem(BuildContext context) {
    return PopupMenuItem(
      value: 'change_exercise',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.swapHoriz,
            semanticLabel: context.l10n.exerciseChangeVariation,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Text(context.l10n.exerciseChangeVariation),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildDuplicateItem(BuildContext context) {
    return PopupMenuItem(
      value: 'duplicate',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.copy,
            semanticLabel: context.l10n.exerciseListDuplicate,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Text(context.l10n.exerciseListDuplicate),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildInsightItem(BuildContext context) {
    return PopupMenuItem(
      value: 'insight',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.insights,
            semanticLabel: context.l10n.exerciseListInsight,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Text(context.l10n.exerciseListInsight),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildCommunityAdviceItem(BuildContext context) {
    return PopupMenuItem(
      value: 'community_advice',
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.tip,
            semanticLabel: context.l10n.communityAdvice,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Text(context.l10n.communityAdvice),
        ],
      ),
    );
  }
}
