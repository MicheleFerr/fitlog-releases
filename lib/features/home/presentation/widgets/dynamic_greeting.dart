import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Dynamic greeting widget that shows time-appropriate greetings
class DynamicGreeting extends ConsumerWidget {
  const DynamicGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    final theme = Theme.of(context);

    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = l10n.goodMorning;
      icon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
      icon = Icons.wb_sunny_outlined;
    } else {
      greeting = l10n.goodEvening;
      icon = Icons.nightlight_round;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              greeting,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Text(
          l10n.readyToDominate,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
