/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Material: AnimatedContainer, Card
/// - analytics/presentation/providers: workoutAnalyticsProvider
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget for celebrating personal record achievements
class PRCelebrationWidget extends ConsumerWidget {
  
  const PRCelebrationWidget({
    super.key,
    this.isFullScreen = false,
  });
  final bool isFullScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final currentPRs = ref.watch(currentPRsProvider);
    
    if (currentPRs.isEmpty) return const SizedBox.shrink();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      child: Card(
        color: colorScheme.secondary.withValues(alpha: 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    AppIcons.celebration,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.personalRecords,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentPRs.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // PR List
              ...currentPRs.take(isFullScreen ? currentPRs.length : 3).map(
                (pr) => _buildPRItem(context, theme, colorScheme, pr, l10n),
              ),
              
              // Show more indicator
              if (!isFullScreen && currentPRs.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.andMoreRecords(currentPRs.length - 3),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPRItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalRecordAchieved pr,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // PR Type Icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                _getPRIcon(pr.type),
                color: colorScheme.secondary,
                size: 14,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Exercise name and type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  pr.typeDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Value and improvement
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPRValue(pr),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
              if (pr.isSignificant)
                Text(
                  pr.formattedImprovement,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPRIcon(PRType type) {
    switch (type) {
      case PRType.weight:
        return AppIcons.workout;
      case PRType.reps:
        return AppIcons.repeat;
      case PRType.volume:
        return AppIcons.trendUp;
      case PRType.oneRM:
        return AppIcons.stars;
      case PRType.totalSets:
        return AppIcons.formatListNumbered;
      case PRType.duration:
        return AppIcons.timer;
    }
  }

  String _formatPRValue(PersonalRecordAchieved pr) {
    switch (pr.type) {
      case PRType.weight:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.reps:
        return '${pr.newValue.toStringAsFixed(0)} reps';
      case PRType.volume:
        return '${pr.newValue.toStringAsFixed(0)} kg';
      case PRType.oneRM:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.totalSets:
        return '${pr.newValue.toStringAsFixed(0)} sets';
      case PRType.duration:
        final minutes = pr.newValue.toInt();
        return '${minutes}m';
    }
  }
}

/// Full-screen PR celebration dialog
class PRCelebrationDialog extends ConsumerWidget {
  const PRCelebrationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final currentPRs = ref.watch(currentPRsProvider);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.secondary.withValues(alpha: 0.8),
              colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.celebration,
                  color: colorScheme.onSecondary,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                l10n.congratulations,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                l10n.newPersonalRecordsAchieved,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // PRs List
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PRCelebrationWidget(isFullScreen: true),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Share and Close buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _shareAchievements(context, ref, currentPRs),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSecondaryContainer,
                        side: BorderSide(color: colorScheme.onSecondaryContainer),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SemanticIcon(
  icon: AppIcons.share,
  semanticLabel: 'Share',
  size: AppIconSize.tiny,
),
                          const SizedBox(width: 8),
                          Text(l10n.share),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                      ),
                      child: Text(l10n.close),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAchievements(
    BuildContext context,
    WidgetRef ref,
    List<PersonalRecordAchieved> prs,
  ) {
    final l10n = AppLocalizations.of(context);
    
    // Generate sharing text
    final achievementText = prs.map((pr) {
      final value = _formatPRValue(pr);
      final improvement = pr.isSignificant ? ' (${pr.formattedImprovement})' : '';
      return '• ${pr.exerciseName}: ${pr.typeDescription} - $value$improvement';
    }).join('\n');
    
    final shareText = '''
🎉 ${l10n.newPersonalRecordsAchieved}

$achievementText

#GymBro #PersonalRecord #Fitness
''';

    // TODO: Implement native sharing
    // Share.share(shareText);
    
    // For now, show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.achievementsCopied),
        action: SnackBarAction(
          label: l10n.ok,
          onPressed: () {},
        ),
      ),
    );
  }

  String _formatPRValue(PersonalRecordAchieved pr) {
    switch (pr.type) {
      case PRType.weight:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.reps:
        return '${pr.newValue.toStringAsFixed(0)} reps';
      case PRType.volume:
        return '${pr.newValue.toStringAsFixed(0)} kg';
      case PRType.oneRM:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.totalSets:
        return '${pr.newValue.toStringAsFixed(0)} sets';
      case PRType.duration:
        final minutes = pr.newValue.toInt();
        return '${minutes}m';
    }
  }
}

/// Floating PR notification
class FloatingPRNotification extends ConsumerStatefulWidget {

  const FloatingPRNotification({
    super.key,
    required this.pr,
    this.onDismiss,
  });
  final PersonalRecordAchieved pr;
  final VoidCallback? onDismiss;

  @override
  ConsumerState<FloatingPRNotification> createState() => _FloatingPRNotificationState();
}

class _FloatingPRNotificationState extends ConsumerState<FloatingPRNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondary,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.celebration,
                  color: colorScheme.onSecondary,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.personalRecord,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.pr.exerciseName}: ${_formatPRValue(widget.pr)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              IconButton(
                onPressed: _dismiss,
                icon: Icon(
                  AppIcons.close,
                  color: colorScheme.onSecondaryContainer,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                iconSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPRValue(PersonalRecordAchieved pr) {
    switch (pr.type) {
      case PRType.weight:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.reps:
        return '${pr.newValue.toStringAsFixed(0)} reps';
      case PRType.volume:
        return '${pr.newValue.toStringAsFixed(0)} kg';
      case PRType.oneRM:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.totalSets:
        return '${pr.newValue.toStringAsFixed(0)} sets';
      case PRType.duration:
        final minutes = pr.newValue.toInt();
        return '${minutes}m';
    }
  }
}
