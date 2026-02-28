/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class TemplateQuotaIndicator extends StatelessWidget {
  const TemplateQuotaIndicator({
    super.key,
    required this.usedPrivate,
    required this.usedPublic,
    required this.maxPrivate,
    required this.maxPublic,
    this.isExpanded = false,
    this.onTap,
  });
  final int usedPrivate;
  final int usedPublic;
  final int maxPrivate;
  final int maxPublic;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.5),
              colorScheme.secondaryContainer.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (sempre visibile)
            Row(
              children: [
                Icon(AppIcons.inventory2, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Template Quota',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'FREE PLAN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    AppIcons.expandMore,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Contenuto espandibile
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 16),

                  // Private templates
                  _buildQuotaBar(
                    context: context,
                    label: 'Private Templates',
                    used: usedPrivate,
                    max: maxPrivate,
                    icon: AppIcons.lock,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(height: 12),

                  // Public templates
                  _buildQuotaBar(
                    context: context,
                    label: 'Public Templates',
                    used: usedPublic,
                    max: maxPublic,
                    icon: AppIcons.public,
                    color: colorScheme.secondary,
                  ),

                  const SizedBox(height: 16),

                  // Upgrade prompt
                  if (usedPrivate >= maxPrivate || usedPublic >= maxPublic)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.star, color: colorScheme.tertiary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need more templates?',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Upgrade to Premium for unlimited templates',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              context.pushNamed(AppRoutes.premiumName);
                            },
                            child: const Text('Upgrade'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaBar({
    required BuildContext context,
    required String label,
    required int used,
    required int max,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = (used / max).clamp(0.0, 1.0);
    final isAlmostFull = percentage >= 0.8;
    final isFull = percentage >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.labelMedium),
            const Spacer(),
            Text(
              '$used / $max',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isFull
                    ? colorScheme.error
                    : isAlmostFull
                    ? context.colors.secondary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isFull
                  ? colorScheme.error
                  : isAlmostFull
                  ? context.colors.secondary
                  : color,
            ),
          ),
        ),
      ],
    );
  }
}
