/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout  
/// 🔧 Type: modal
/// 🌍 Localization: ✅ Full support
/// 🎨 Theme: ✅ Adaptive
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class CommunityAdviceModal extends ConsumerStatefulWidget {

  const CommunityAdviceModal({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  ConsumerState<CommunityAdviceModal> createState() =>
      _CommunityAdviceModalState();
}

class _CommunityAdviceModalState extends ConsumerState<CommunityAdviceModal> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    // Get approved contributions for this exercise
    final contributionsAsync = ref.watch(
      exerciseContributionsProvider(widget.exercise.id),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Icon(
                    AppIcons.tip,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.communityAdvice,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.exercise.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: contributionsAsync.when(
                data: (contributions) {
                  // Filter approved contributions only
                  final approvedContributions = contributions
                      .where((c) => c.status == ContributionStatus.approved)
                      .toList();

                  // Sort by upvotes (most helpful first)
                  approvedContributions.sort((a, b) => b.upvotes.compareTo(a.upvotes));

                  if (approvedContributions.isEmpty) {
                    return _buildEmptyState(context, l10n, theme);
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: approvedContributions.length,
                    itemBuilder: (context, index) {
                      final contribution = approvedContributions[index];
                      return _buildContributionCard(context, contribution, theme, l10n);
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.error,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Errore nel caricamento',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.tip,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAdviceAvailable,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.beFirstToShare,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionCard(
    BuildContext context,
    CommunityContribution contribution,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final contributionSubmission = ref.read(contributionSubmissionProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and author
            Row(
              children: [
                _getTypeIcon(contribution.type, theme),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contribution.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              contribution.description,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // Footer with author and like button
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.personOutline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        contribution.userName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Like button
                InkWell(
                  onTap: () => contributionSubmission.voteOnContribution(
                    contribution.id,
                    true,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.thumbUpOutlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contribution.upvotes.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Helpful text if upvotes > 0
            if (contribution.upvotes > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.peopleFoundHelpful(contribution.upvotes),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getTypeIcon(ContributionType type, ThemeData theme) {
    switch (type) {
      case ContributionType.tip:
        return const Icon(
          AppIcons.lightbulb,
          size: 20,
          color: Colors.amber,
        );
      case ContributionType.warning:
        return const Icon(
          AppIcons.warning,
          size: 20,
          color: Colors.orange,
        );
      case ContributionType.correction:
        return Icon(
          AppIcons.edit,
          size: 20,
          color: theme.colorScheme.primary,
        );
      case ContributionType.variant:
        return const Icon(
          AppIcons.altRoute,
          size: 20,
          color: Colors.purple,
        );
      case ContributionType.translation:
        return const Icon(
          AppIcons.translate,
          size: 20,
          color: Colors.blue,
        );
      case ContributionType.technique:
        return const Icon(
          AppIcons.workout,
          size: 20,
          color: Colors.green,
        );
    }
  }
}
