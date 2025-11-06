import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// 🎯 TIER-1 IMPROVEMENT COMPONENTS
/// Componenti riutilizzabili per rendere Analytics tier-1

// ============================================================================
// 1. HELP BUTTON UNIVERSALE
// ============================================================================

class HelpButton extends StatelessWidget {

  const HelpButton({
    super.key,
    required this.topic,
    this.customTitle,
    this.customContent,
    this.additionalActions,
    this.icon = AppIcons.help,
    this.size = 18,
  });
  final String topic;
  final String? customTitle;
  final String? customContent;
  final List<Widget>? additionalActions;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return IconButton(
      icon: Icon(icon, size: size),
      color: theme.colorScheme.onSurfaceVariant,
      tooltip: l10n.whatDoesThisMean,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: size + 8,
        minHeight: size + 8,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        _showHelpDialog(context);
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.info, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customTitle ?? _getDefaultTitle(topic, l10n),
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customContent ?? _getDefaultContent(topic, l10n),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildExampleCard(context, topic),
            ],
          ),
        ),
        actions: [
          if (additionalActions != null) ...additionalActions!,
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  String _getDefaultTitle(String topic, AppLocalizations l10n) {
    return switch (topic) {
      'totalVolume' => l10n.whatIsTotalVolume,
      'totalSets' => l10n.whatAreTotalSets,
      'workoutFrequency' => l10n.whatIsWorkoutFrequency,
      'muscleBalance' => l10n.whatIsMuscleBalance,
      'personalRecord' => l10n.whatIsPersonalRecord,
      _ => l10n.helpTitle,
    };
  }

  String _getDefaultContent(String topic, AppLocalizations l10n) {
    return switch (topic) {
      'totalVolume' => l10n.totalVolumeExplanation,
      'totalSets' => l10n.totalSetsExplanation,
      'workoutFrequency' => l10n.workoutFrequencyExplanation,
      'muscleBalance' => l10n.muscleBalanceExplanation,
      'personalRecord' => l10n.personalRecordExplanation,
      _ => l10n.defaultHelpContent,
    };
  }

  Widget _buildExampleCard(BuildContext context, String topic) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.example,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getExampleText(topic, l10n),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getExampleText(String topic, AppLocalizations l10n) {
    return switch (topic) {
      'totalVolume' => l10n.totalVolumeExample,
      'totalSets' => l10n.totalSetsExample,
      'workoutFrequency' => l10n.workoutFrequencyExample,
      'muscleBalance' => l10n.muscleBalanceExample,
      'personalRecord' => l10n.personalRecordExample,
      _ => '',
    };
  }
}

// ============================================================================
// 2. METRIC CARD INTERATTIVA
// ============================================================================

class InteractiveMetricCard extends StatefulWidget {

  const InteractiveMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.iconColor,
    this.previousValue,
    this.helpTopic,
    this.onTap,
    this.expandedContent,
    this.tooltip,
  });
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? iconColor;
  final double? previousValue;
  final String? helpTopic;
  final VoidCallback? onTap;
  final Widget? expandedContent;
  final String? tooltip;

  @override
  State<InteractiveMetricCard> createState() => _InteractiveMetricCardState();
}

class _InteractiveMetricCardState extends State<InteractiveMetricCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: (_) => _handleTapDown(),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: () => _handleTapCancel(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isPressed
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: _isPressed ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? theme.colorScheme.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor ?? theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (widget.helpTopic != null)
                      HelpButton(
                        topic: widget.helpTopic!,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Value with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: double.tryParse(widget.value) ?? 0,
                  ),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value.toStringAsFixed(
                            widget.unit == 't' ? 1 : 0,
                          ),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (widget.unit != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            widget.unit!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                
                // Trend indicator
                if (widget.previousValue != null) ...[
                  const SizedBox(height: 8),
                  TrendIndicator(
                    current: double.tryParse(widget.value) ?? 0,
                    previous: widget.previousValue!,
                  ),
                ],
                
                // Expanded content
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded && widget.expandedContent != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: widget.expandedContent,
                        )
                      : const SizedBox.shrink(),
                ),
                
                // Tap hint
                if (widget.onTap != null || widget.expandedContent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isExpanded ? l10n.tapToCollapse : l10n.tapForDetails,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp() {
    setState(() {
      _isPressed = false;
      _isExpanded = !_isExpanded;
    });
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
}

// ============================================================================
// 3. TREND INDICATOR
// ============================================================================

class TrendIndicator extends StatelessWidget {

  const TrendIndicator({
    super.key,
    required this.current,
    required this.previous,
    this.showPercentage = true,
    this.showAbsolute = false,
  });
  final double current;
  final double previous;
  final bool showPercentage;
  final bool showAbsolute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final difference = current - previous;
    final percentage = previous > 0 ? (difference / previous * 100) : 0.0;
    final isPositive = difference >= 0;
    
    final color = isPositive ? context.successColor : context.errorColor;
    final icon = isPositive ? AppIcons.trendUp : AppIcons.trendDown;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          if (showAbsolute) ...[
            Text(
              '${isPositive ? '+' : ''}${difference.toStringAsFixed(1)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showPercentage) const SizedBox(width: 4),
          ],
          if (showPercentage)
            Text(
              '(${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            l10n.vsLastPeriod,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. INSIGHT CARD
// ============================================================================

class InsightCard extends StatelessWidget {

  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.type = InsightType.info,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final InsightType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.background.withValues(alpha: 0.8),
            colors.background.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: colors.icon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.text.withValues(alpha: 0.9),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            action!,
          ],
        ],
      ),
    );
  }

  InsightColors _getColors(ThemeData theme) {
    return switch (type) {
      InsightType.success => InsightColors(
          background: context.successColor,
          border: context.successColor.shade700,
          icon: context.successColor.shade900,
          iconBackground: context.successColor.shade100,
          text: context.successColor.shade900,
        ),
      InsightType.warning => InsightColors(
          background: context.warningColor,
          border: context.warningColor.shade700,
          icon: context.warningColor.shade900,
          iconBackground: context.warningColor.shade100,
          text: context.warningColor.shade900,
        ),
      InsightType.error => InsightColors(
          background: context.errorColor,
          border: context.errorColor.shade700,
          icon: context.errorColor.shade900,
          iconBackground: context.errorColor.shade100,
          text: context.errorColor.shade900,
        ),
      InsightType.info => InsightColors(
          background: theme.colorScheme.primary,
          border: theme.colorScheme.primary,
          icon: theme.colorScheme.primary,
          iconBackground: theme.colorScheme.primaryContainer,
          text: theme.colorScheme.onPrimaryContainer,
        ),
    };
  }
}

enum InsightType { success, warning, error, info }

class InsightColors {

  InsightColors({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconBackground,
    required this.text,
  });
  final Color background;
  final Color border;
  final Color icon;
  final Color iconBackground;
  final Color text;
}

// ============================================================================
// 5. EMPTY STATE MOTIVAZIONALE
// ============================================================================

class MotivationalEmptyState extends StatelessWidget {

  const MotivationalEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.motivationalQuote,
    this.onAction,
    this.actionLabel,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? motivationalQuote;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.secondary.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Motivational quote
            if (motivationalQuote != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      AppIcons.formatQuote,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      motivationalQuote!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            // Action button
            if (onAction != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onAction!();
                },
                icon: const Icon(AppIcons.rocket),
                label: Text(actionLabel ?? l10n.startNow),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            
            // Tips
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.tip,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.proTip,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. STREAK WIDGET
// ============================================================================

class StreakWidget extends StatelessWidget {

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.nextMilestone,
    this.motivationalMessage,
  });
  final int currentStreak;
  final int longestStreak;
  final int nextMilestone;
  final String? motivationalMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final daysToMilestone = nextMilestone - currentStreak;
    final progressToMilestone = currentStreak / nextMilestone;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,  // Material orange shade
            context.warningColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.warningColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.streak,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentStreak,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currentStreak.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.days,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.longestStreak,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '$longestStreak ${l10n.days}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress to milestone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.nextMilestone,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '$daysToMilestone ${l10n.daysToGo}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressToMilestone,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          
          // Motivational message
          if (motivationalMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.star,
                    color: context.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      motivationalMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
