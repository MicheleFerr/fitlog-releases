import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/home/providers/daily_login_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/level_system.dart';

class DailyLoginBonusWidget extends ConsumerWidget {
  const DailyLoginBonusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final loginState = ref.watch(dailyLoginProvider);
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
        onTap: loginState.bonusClaimedToday 
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
              colors: loginState.bonusClaimedToday
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface,
                  ]
                : [
                    Colors.amber.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.05),
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
                    colors: loginState.bonusClaimedToday
                      ? [
                          theme.colorScheme.outline.withValues(alpha: 0.3),
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                        ]
                      : [Colors.amber, Colors.orange],
                  ),
                  boxShadow: loginState.bonusClaimedToday 
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                ),
                child: Icon(
                  loginState.bonusClaimedToday 
                    ? Icons.check_circle
                    : Icons.card_giftcard,
                  color: Colors.white,
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
                          'Bonus Giornaliero',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (loginState.consecutiveDays > 0)
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
                              '🔥 ${loginState.consecutiveDays} giorni',
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
                    if (loginState.bonusClaimedToday) ...[
                      Text(
                        '✅ Bonus di oggi reclamato: +${bonusInfo.currentDayBonus} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (!bonusInfo.isMaxBonus)
                        Text(
                          'Torna domani per +${bonusInfo.nextDayBonus} XP!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ] else ...[
                      Text(
                        'Reclama +${bonusInfo.currentDayBonus} XP',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade700,
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
              if (!loginState.bonusClaimedToday)
                Column(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Colors.amber,
                      size: 20,
                    ),
                    Text(
                      'TAP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white),
                const SizedBox(width: 12),
                Text('Hai guadagnato +${bonusInfo.currentDayBonus} XP!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
    final loginState = ref.watch(dailyLoginProvider);
    final currentDay = loginState.consecutiveDays;
    
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
            'Progressione Bonus Login',
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
              final isToday = day == currentDay && !loginState.bonusClaimedToday;
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
                            colors: [Colors.green, Colors.green.shade700],
                          )
                        : isToday
                          ? const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            )
                          : null,
                      color: isFuture 
                        ? theme.colorScheme.outline.withValues(alpha: 0.2)
                        : null,
                      boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                    ),
                    child: Center(
                      child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            day.toString(),
                            style: TextStyle(
                              color: isToday 
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+$xp',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCompleted 
                        ? Colors.green
                        : isToday
                          ? Colors.amber.shade700
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    'XP',
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bonus massimo raggiunto! 100 XP ogni giorno',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
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