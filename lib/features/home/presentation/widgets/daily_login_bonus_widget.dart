import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/providers/daily_login_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/level_system.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class DailyLoginBonusWidget extends ConsumerWidget {
  const DailyLoginBonusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // ⚡ OPTIMIZATION: Watch only specific properties instead of entire DailyLoginState
    final bonusClaimedToday = ref.watch(dailyLoginProvider.select((s) => s.bonusClaimedToday));
    final consecutiveDays = ref.watch(dailyLoginProvider.select((s) => s.consecutiveDays));
    final bonusInfo = ref.read(dailyLoginProvider.notifier).getBonusInfo();
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: bonusClaimedToday 
          ? null 
          : () => _claimBonus(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bonusClaimedToday
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface,
                  ]
                : [
                    context.colors.warning.withValues(alpha: 0.1),
                    context.colors.warning.withValues(alpha: 0.05),
                  ],
            ),
          ),
          child: Row(
            children: [
              // Icona con animazione
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: bonusClaimedToday
                      ? [
                          theme.colorScheme.outline.withValues(alpha: 0.3),
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                        ]
                      : [context.colors.warning, context.colors.error],
                  ),
                  boxShadow: bonusClaimedToday
                    ? []
                    : [
                        BoxShadow(
                          color: context.colors.warning.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                ),
                child: Icon(
                  bonusClaimedToday 
                    ? AppIcons.complete
                    : AppIcons.gift,
                  color: context.colors.surface,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l10n.dailyBonus,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (consecutiveDays > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.l10n.daysStreak(consecutiveDays),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (bonusClaimedToday) ...[
                      Text(
                        context.l10n.todayBonusClaimed(bonusInfo.currentDayBonus),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (!bonusInfo.isMaxBonus)
                        Text(
                          context.l10n.comeTomorrowForBonus(bonusInfo.nextDayBonus),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ] else ...[
                      Text(
                        context.l10n.claimBonus(bonusInfo.currentDayBonus),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bonusInfo.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Visualizzazione progressione
              if (!bonusClaimedToday)
                Column(
                  children: [
                    Icon(
                      AppIcons.touchApp,
                      color: context.colors.warning,
                      size: 20,
                    ),
                    Text(
                      context.l10n.tap,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: context.colors.warning,
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
  
  void _claimBonus(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(dailyLoginProvider.notifier).claimDailyBonus();

    if (success) {
      final bonusInfo = ref.read(dailyLoginProvider.notifier).getBonusInfo();

      // Mostra animazione di successo
      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.youEarnedBonus(bonusInfo.currentDayBonus),
        );
      }
    }
  }
}

// Widget per mostrare la progressione dei prossimi giorni
class DailyLoginProgressionWidget extends ConsumerWidget {
  const DailyLoginProgressionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // ⚡ OPTIMIZATION: Watch only specific properties instead of entire DailyLoginState
    final consecutiveDays = ref.watch(dailyLoginProvider.select((s) => s.consecutiveDays));
    final bonusClaimedToday = ref.watch(dailyLoginProvider.select((s) => s.bonusClaimedToday));
    final currentDay = consecutiveDays;
    
    // Mostra progressione dei prossimi 7 giorni
    final days = List.generate(7, (i) => i + 1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.loginBonusProgression,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final xp = LevelSystem.calculateDailyLoginBonus(day);
              final isCompleted = day <= currentDay;
              final isToday = day == currentDay && !bonusClaimedToday;
              final isFuture = day > currentDay;
              
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCompleted
                        ? LinearGradient(
                            colors: [context.colors.success, context.colors.success.withValues(alpha: 0.7)],
                          )
                        : isToday
                          ? LinearGradient(
                              colors: [context.colors.warning, context.colors.error],
                            )
                          : null,
                      color: isFuture
                        ? theme.colorScheme.outline.withValues(alpha: 0.2)
                        : null,
                      boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: context.colors.warning.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                    ),
                    child: Center(
                      child: isCompleted
                        ? Icon(
                            AppIcons.check,
                            color: context.colors.surface,
                            size: 20,
                          )
                        : Text(
                            day.toString(),
                            style: TextStyle(
                              color: isToday 
                                ? context.colors.surface
                                : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.xpGain(xp),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                        ? context.colors.success
                        : isToday
                          ? context.colors.warning
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    context.l10n.xpLabel,
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (currentDay >= 7) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.star,
                    color: context.colors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.maxBonusReached,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.success,
                        fontWeight: FontWeight.w600,
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
