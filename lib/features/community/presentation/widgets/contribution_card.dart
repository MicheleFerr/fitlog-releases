import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContributionCard extends ConsumerWidget {
  const ContributionCard({
    required this.contribution,
    super.key,
  });

  final CommunityContribution contribution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if contribution is saved by looking at saved IDs list
    final savedIdsAsync = ref.watch(savedContributionIdsProvider);
    final isSaved = savedIdsAsync.whenOrNull(
      data: (ids) => ids.contains(contribution.id),
    ) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          // TODO: Navigate to contribution detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type badge + Author
              Row(
                children: [
                  _buildTypeBadge(context),
                  SizedBox(width: 8),
                  _buildDifficultyBadge(context),
                  const Spacer(),
                  _buildAuthorInfo(context),
                ],
              ),

              SizedBox(height: 12),

              // Title
              Text(
                contribution.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8),

              // Description preview
              Text(
                contribution.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12),

              // Footer: Stats + Save button
              Row(
                children: [
                  // Upvotes
                  SemanticIcon(
                    icon: AppIcons.thumbUp,
                    semanticLabel: context.l10n.upvotes,
                    size: AppIconSize.small,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 4),
                  Text(
                    contribution.upvotes.toString(),
                    style: context.textTheme.bodySmall,
                  ),

                  SizedBox(width: 16),

                  // Comments
                  SemanticIcon(
                    icon: AppIcons.comment,
                    semanticLabel: context.l10n.comments,
                    size: AppIconSize.small,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 4),
                  Text(
                    contribution.comments.length.toString(),
                    style: context.textTheme.bodySmall,
                  ),

                  SizedBox(width: 16),

                  // Saves
                  SemanticIcon(
                    icon: AppIcons.bookmark,
                    semanticLabel: context.l10n.saves,
                    size: AppIconSize.small,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 4),
                  Text(
                    contribution.saves.toString(),
                    style: context.textTheme.bodySmall,
                  ),

                  const Spacer(),

                  // Time ago
                  Text(
                    timeago.format(contribution.createdAt),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Save button
                  IconButton(
                    icon: SemanticIcon(
                      icon: isSaved ? AppIcons.bookmarkFilled : AppIcons.bookmark,
                      semanticLabel: context.l10n.bookmarkContribution,
                      color: isSaved ? context.colors.primary : null,
                      size: AppIconSize.medium,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final notifier = ref.read(saveContributionProvider.notifier);
                      if (isSaved) {
                        notifier.unsaveContribution(contribution.id);
                      } else {
                        notifier.saveContribution(contribution.id);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final typeColor = _getTypeColor(context);
    final typeLabel = _getTypeLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        typeLabel,
        style: context.textTheme.bodySmall?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context) {
    final difficultyColor = _getDifficultyColor(context);
    final difficultyLabel = _getDifficultyLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: difficultyColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: difficultyColor, width: 1),
      ),
      child: Text(
        difficultyLabel,
        style: context.textTheme.bodySmall?.copyWith(
          color: difficultyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        if (contribution.userAvatar != null)
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(contribution.userAvatar!),
          )
        else
          CircleAvatar(
            radius: 12,
            backgroundColor: context.colors.primaryContainer,
            child: Text(
              contribution.userName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
        SizedBox(width: 6),
        Text(
          contribution.userName,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(BuildContext context) {
    switch (contribution.type) {
      case ContributionType.tip:
        return context.colors.tertiary;
      case ContributionType.technique:
        return context.colors.primary;
      case ContributionType.warning:
        return context.colors.error;
      case ContributionType.variant:
        return context.colors.secondary;
      case ContributionType.correction:
        return context.colors.warning;
      case ContributionType.translation:
        return context.colors.tertiary;
    }
  }

  String _getTypeLabel(BuildContext context) {
    switch (contribution.type) {
      case ContributionType.tip:
        return context.l10n.contributionTypeTip;
      case ContributionType.technique:
        return context.l10n.contributionTypeTechnique;
      case ContributionType.warning:
        return context.l10n.contributionTypeWarning;
      case ContributionType.variant:
        return context.l10n.contributionTypeVariant;
      case ContributionType.correction:
        return context.l10n.contributionTypeCorrection;
      case ContributionType.translation:
        return context.l10n.contributionTypeTranslation;
    }
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (contribution.difficulty) {
      case 'beginner':
        return context.colors.success;
      case 'intermediate':
        return context.colors.warning;
      case 'advanced':
        return context.colors.error;
      default:
        return context.colors.onSurface;
    }
  }

  String _getDifficultyLabel(BuildContext context) {
    switch (contribution.difficulty) {
      case 'beginner':
        return context.l10n.difficultyBeginner;
      case 'intermediate':
        return context.l10n.difficultyIntermediate;
      case 'advanced':
        return context.l10n.difficultyAdvanced;
      default:
        return contribution.difficulty;
    }
  }
}
