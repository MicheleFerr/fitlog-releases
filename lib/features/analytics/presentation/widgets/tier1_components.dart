import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Universal help button with explanations
class HelpButton extends StatelessWidget {

  const HelpButton({
    super.key,
    required this.metricKey,
    this.customTooltip,
    this.onTap,
  });
  final String metricKey;
  final String? customTooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return IconButton(
      icon: Icon(
        Icons.help_outline,
        size: 16,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      tooltip: customTooltip ?? _getTooltip(context, metricKey),
      onPressed: onTap ?? () => _showHelpDialog(context),
    );
  }

  String _getTooltip(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    // Map metric keys to localized tooltips
    final tooltips = {
      'volume': localizations.volumeExplanationDesc,
      'sets': localizations.setsExplanation,
      'intensity': localizations.intensityExplanation,
      'streak': localizations.streakExplanation,
      'oneRm': localizations.oneRmExplanation,
    };
    return tooltips[key] ?? localizations.tapForMoreInfo;
  }

  void _showHelpDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(_getTitle(context, metricKey)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getExplanation(context, metricKey),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildFormula(context),
              const SizedBox(height: 16),
              _buildExamples(context),
              const SizedBox(height: 16),
              _buildTips(context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.gotIt),
          ),
        ],
      ),
    );
  }

  String _getTitle(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    final titles = {
      'volume': localizations.volumeExplanation,
      'sets': localizations.setsExplanation,
      'intensity': localizations.intensityExplanation,
      'streak': localizations.streakExplanation,
      'oneRm': localizations.oneRmExplanation,
    };
    return titles[key] ?? localizations.helpTitle;
  }

  String _getExplanation(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    final explanations = {
      'volume': localizations.volumeExplanationDesc,
      'sets': localizations.setsExplanationDesc,
      'intensity': localizations.intensityExplanationDesc,
      'streak': localizations.streakExplanationDesc,
      'oneRm': localizations.oneRmExplanationDesc,
    };
    return explanations[key] ?? '';
  }

  Widget _buildFormula(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.functions, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  localizations.formula,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getFormula(metricKey),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormula(String key) {
    final formulas = {
      'volume': 'Volume = Σ(Sets × Reps × Weight)',
      'sets': 'Total Sets = Count of all sets',
      'intensity': 'Intensity = (Weight / 1RM) × 100%',
      'streak': 'Streak = Consecutive workout days',
      'oneRm': '1RM = Weight × (1 + Reps/30)',
    };
    return formulas[key] ?? '';
  }

  Widget _buildExamples(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  localizations.example,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_getExample(context, metricKey)),
          ],
        ),
      ),
    );
  }

  String _getExample(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    final examples = {
      'volume': '3 sets × 10 reps × 50kg = 1500kg total',
      'sets': '4 exercises × 3 sets = 12 total sets',
      'intensity': '80kg lift with 100kg 1RM = 80% intensity',
      'streak': '5 consecutive days = 5 day streak',
      'oneRm': '80kg × 5 reps ≈ 93kg 1RM',
    };
    return examples[key] ?? '';
  }

  Widget _buildTips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Card(
      color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.tipsAndUpdates, size: 16, color: colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  localizations.proTip,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_getTip(context, metricKey)),
          ],
        ),
      ),
    );
  }

  String _getTip(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    final tips = {
      'volume': localizations.volumeTip,
      'sets': localizations.setsTip,
      'intensity': localizations.intensityTip,
      'streak': localizations.streakTip,
      'oneRm': localizations.oneRmTip,
    };
    return tips[key] ?? localizations.generalTip;
  }
}

/// Interactive metric card with animations
class InteractiveMetricCard extends StatefulWidget {

  const InteractiveMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.color,
    this.previousValue,
    this.onTap,
    this.onLongPress,
    this.helpKey,
  });
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? color;
  final double? previousValue;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? helpKey;

  @override
  State<InteractiveMetricCard> createState() => _InteractiveMetricCardState();
}

class _InteractiveMetricCardState extends State<InteractiveMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = widget.color ?? colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _isPressed ? 2 : 4,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      effectiveColor.withValues(alpha: 0.1),
                      effectiveColor.withValues(alpha: 0.05),
                    ],
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
                            color: effectiveColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.icon,
                            color: effectiveColor,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        if (widget.helpKey != null)
                          HelpButton(metricKey: widget.helpKey!),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: double.tryParse(widget.value.replaceAll(',', '')) ?? 0,
                          ),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedValue, child) {
                            return Text(
                              animatedValue.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: effectiveColor,
                              ),
                            );
                          },
                        ),
                        if (widget.unit != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            widget.unit!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: effectiveColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.previousValue != null) ...[
                      const SizedBox(height: 8),
                      TrendIndicator(
                        current: double.tryParse(widget.value.replaceAll(',', '')) ?? 0,
                        previous: widget.previousValue!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Trend indicator with animations
class TrendIndicator extends StatelessWidget {

  const TrendIndicator({
    super.key,
    required this.current,
    required this.previous,
    this.showPercentage = true,
  });
  final double current;
  final double previous;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final difference = current - previous;
    final percentage = previous != 0 ? (difference / previous * 100) : 0.0;
    final isPositive = difference > 0;
    final isNeutral = difference == 0;

    final color = isNeutral
        ? Colors.grey
        : isPositive
            ? Colors.green
            : Colors.orange;

    final icon = isNeutral
        ? Icons.trending_flat
        : isPositive
            ? Icons.trending_up
            : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          isNeutral
              ? '0%'
              : '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Motivational empty state
class MotivationalEmptyState extends StatelessWidget {

  const MotivationalEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.motivationalQuote,
    this.proTip,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? motivationalQuote;
  final String? proTip;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (motivationalQuote != null) ...[
              const SizedBox(height: 24),
              Card(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: colorScheme.secondary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        motivationalQuote!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (proTip != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.proTip,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            Text(
                              proTip!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onAction();
              },
              icon: const Icon(Icons.fitness_center),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}