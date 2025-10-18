import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/progressive_overload_data.dart';

/// Widget che fornisce consigli contestuali invece di un numero astratto
class ContextualTrainingAdvisor extends StatelessWidget {

  const ContextualTrainingAdvisor({
    super.key,
    required this.currentWeekVolume,
    required this.previousWeekVolume,
    required this.avgIntensity,
    required this.fatigueHistory,
    required this.workoutCount,
    required this.lastWorkoutDate,
    this.isPremium = false,
  });
  final double currentWeekVolume;
  final double previousWeekVolume;
  final double avgIntensity; // RPE medio 6-10
  final List<FatigueEntry> fatigueHistory;
  final int workoutCount;
  final DateTime lastWorkoutDate;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final advice = _generateContextualAdvice();
    final category = _getAdviceCategory();
    
    return InkWell(
      onTap: () => _showDetailedExplanation(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getGradientColors(category),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors(category).first.withValues(alpha: 0.3),
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
                Icon(
                  _getAdviceIcon(category),
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '💡 Training Insight',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap for details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Main advice message
            Text(
              advice.mainMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
            ),
            
            if (advice.subMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      advice.subIcon ?? Icons.info_outline,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        advice.subMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Quick stats
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat(
                  'Volume Change',
                  '${_getVolumeChangePercent().toStringAsFixed(1)}%',
                  _getVolumeChangePercent() > 0 ? Icons.trending_up : Icons.trending_down,
                  theme,
                ),
                _buildQuickStat(
                  'Avg Intensity',
                  _formatIntensity(avgIntensity),
                  Icons.flash_on,
                  theme,
                ),
                _buildQuickStat(
                  'Recovery',
                  _getRecoveryStatus(),
                  Icons.hotel,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(AdviceCategory category) {
    switch (category) {
      case AdviceCategory.pushHard:
        return [Colors.green.shade400, Colors.green.shade600];
      case AdviceCategory.maintainPace:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case AdviceCategory.beCareful:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case AdviceCategory.takeRest:
        return [Colors.red.shade400, Colors.red.shade600];
      case AdviceCategory.recovery:
        return [Colors.purple.shade400, Colors.purple.shade600];
    }
  }

  IconData _getAdviceIcon(AdviceCategory category) {
    switch (category) {
      case AdviceCategory.pushHard:
        return Icons.rocket_launch;
      case AdviceCategory.maintainPace:
        return Icons.directions_run;
      case AdviceCategory.beCareful:
        return Icons.warning_amber;
      case AdviceCategory.takeRest:
        return Icons.hotel;
      case AdviceCategory.recovery:
        return Icons.spa;
    }
  }

  AdviceCategory _getAdviceCategory() {
    final volumeChange = _getVolumeChangePercent();
    final avgFatigue = _getAverageFatigue();
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inDays;
    
    // Logica contestuale per determinare la categoria
    if (volumeChange < -30 && avgFatigue > 3.5) {
      return AdviceCategory.takeRest;
    } else if (volumeChange < -15 || avgFatigue > 4) {
      return AdviceCategory.recovery;
    } else if (volumeChange > 10 && avgFatigue < 3) {
      return AdviceCategory.pushHard;
    } else if (daysSinceLastWorkout > 3) {
      return AdviceCategory.beCareful;
    } else {
      return AdviceCategory.maintainPace;
    }
  }

  ContextualAdvice _generateContextualAdvice() {
    final volumeChange = _getVolumeChangePercent();
    final avgFatigue = _getAverageFatigue();
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inDays;
    final normalizedIntensity = _normalizeIntensity(avgIntensity);
    
    // Analisi contestuale completa
    if (volumeChange < -30) {
      if (avgFatigue > 3.5) {
        return ContextualAdvice(
          mainMessage: 'Il tuo corpo sta chiedendo riposo. Il volume è calato del ${volumeChange.abs().toStringAsFixed(0)}% e la fatica è alta.',
          subMessage: 'Considera 2-3 giorni di recupero completo o un allenamento molto leggero.',
          subIcon: Icons.spa,
        );
      } else {
        return ContextualAdvice(
          mainMessage: 'Settimana di scarico rilevata. Volume ridotto del ${volumeChange.abs().toStringAsFixed(0)}%.',
          subMessage: 'Se pianificato, ottimo! Altrimenti, verifica se stai recuperando bene.',
          subIcon: Icons.check_circle,
        );
      }
    } else if (volumeChange > 15) {
      if (avgFatigue < 3) {
        return ContextualAdvice(
          mainMessage: 'Ottima progressione! Volume aumentato del ${volumeChange.toStringAsFixed(0)}% con fatica gestibile.',
          subMessage: 'Puoi mantenere questo ritmo, ma monitora il recupero nei prossimi giorni.',
          subIcon: Icons.rocket_launch,
        );
      } else {
        return ContextualAdvice(
          mainMessage: 'Volume aumentato del ${volumeChange.toStringAsFixed(0)}%, ma la fatica è elevata.',
          subMessage: 'Considera di mantenere il volume attuale per consolidare i progressi.',
          subIcon: Icons.warning_amber,
        );
      }
    } else if (daysSinceLastWorkout > 4) {
      return ContextualAdvice(
        mainMessage: "Sono passati $daysSinceLastWorkout giorni dall'ultimo allenamento.",
        subMessage: 'Riparti con calma, magari con un volume ridotto del 20-30%.',
        subIcon: Icons.directions_walk,
      );
    } else if (normalizedIntensity > 8) {
      return ContextualAdvice(
        mainMessage: 'Intensità molto alta questa settimana (RPE medio: ${normalizedIntensity.toStringAsFixed(1)}).',
        subMessage: 'Assicurati di bilanciare con giorni di recupero adeguati.',
        subIcon: Icons.flash_on,
      );
    } else if (workoutCount >= 5) {
      return ContextualAdvice(
        mainMessage: 'Frequenza di allenamento elevata con $workoutCount sessioni questa settimana.',
        subMessage: avgFatigue > 3 
            ? 'Valuta se ridurre la frequenza per migliorare il recupero.'
            : 'Ottimo ritmo! Continua a monitorare i segnali del corpo.',
        subIcon: Icons.calendar_today,
      );
    } else {
      // Messaggio standard basato su performance generale
      return ContextualAdvice(
        mainMessage: "Settimana equilibrata con volume ${volumeChange > 0 ? 'in crescita' : 'stabile'}.",
        subMessage: 'Continua così, ascoltando sempre i segnali del tuo corpo.',
        subIcon: Icons.thumb_up,
      );
    }
  }

  double _getVolumeChangePercent() {
    if (previousWeekVolume == 0) return 0;
    return ((currentWeekVolume - previousWeekVolume) / previousWeekVolume * 100);
  }

  double _getAverageFatigue() {
    if (fatigueHistory.isEmpty) return 3.0; // Default medio
    final sum = fatigueHistory.fold(0, (sum, entry) => sum + entry.fatigueLevel);
    return sum / fatigueHistory.length;
  }

  double _normalizeIntensity(double rpeIntensity) {
    // Converte da scala 1-10 a RPE reale 6-10
    if (rpeIntensity <= 5) return 6.0;
    return 6.0 + (rpeIntensity - 1) * 4 / 9;
  }

  String _formatIntensity(double intensity) {
    final normalized = _normalizeIntensity(intensity);
    return 'RPE ${normalized.toStringAsFixed(1)}';
  }

  String _getRecoveryStatus() {
    final avgFatigue = _getAverageFatigue();
    if (avgFatigue < 2) return 'Great';
    if (avgFatigue < 3) return 'Good';
    if (avgFatigue < 4) return 'Fair';
    return 'Poor';
  }

  void _showDetailedExplanation(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailedExplanationSheet(
        volumeChange: _getVolumeChangePercent(),
        avgIntensity: avgIntensity,
        avgFatigue: _getAverageFatigue(),
        workoutCount: workoutCount,
        daysSinceLastWorkout: DateTime.now().difference(lastWorkoutDate).inDays,
        isPremium: isPremium,
      ),
    );
  }
}

class _DetailedExplanationSheet extends StatelessWidget {

  const _DetailedExplanationSheet({
    required this.volumeChange,
    required this.avgIntensity,
    required this.avgFatigue,
    required this.workoutCount,
    required this.daysSinceLastWorkout,
    required this.isPremium,
  });
  final double volumeChange;
  final double avgIntensity;
  final double avgFatigue;
  final int workoutCount;
  final int daysSinceLastWorkout;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              '📊 Analisi Dettagliata',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildExplanationCard(
              context,
              'Volume Training',
              'Il volume è ${volumeChange > 0 ? "aumentato" : "diminuito"} del ${volumeChange.abs().toStringAsFixed(1)}%',
              _getVolumeExplanation(),
              volumeChange > 0 ? Icons.trending_up : Icons.trending_down,
              volumeChange > 0 ? Colors.green : Colors.orange,
            ),
            
            _buildExplanationCard(
              context,
              'Intensità Media',
              'RPE ${(6 + (avgIntensity - 1) * 4 / 9).toStringAsFixed(1)} su 10',
              _getIntensityExplanation(),
              Icons.flash_on,
              _getIntensityColor(),
            ),
            
            _buildExplanationCard(
              context,
              'Stato di Recupero',
              'Fatica media: ${avgFatigue.toStringAsFixed(1)}/5',
              _getRecoveryExplanation(),
              Icons.hotel,
              _getFatigueColor(),
            ),
            
            _buildExplanationCard(
              context,
              'Frequenza',
              '$workoutCount allenamenti questa settimana',
              _getFrequencyExplanation(),
              Icons.calendar_today,
              Colors.blue,
            ),
            
            if (!isPremium) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🎯 Sblocca Analisi Avanzate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Previsioni personalizzate basate su AI\n'
                      '• Suggerimenti di recupero ottimale\n'
                      '• Piano di progressione automatico\n'
                      '• Analisi biomeccanica degli esercizi',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(
    BuildContext context,
    String title,
    String value,
    String explanation,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getVolumeExplanation() {
    if (volumeChange > 15) {
      return 'Grande aumento di volume! Assicurati di recuperare adeguatamente. '
             'Se ti senti bene, puoi mantenere questo ritmo per 2-3 settimane prima di una settimana di scarico.';
    } else if (volumeChange > 5) {
      return "Progressione moderata e sostenibile. Questo è l'incremento ideale per costruire forza "
             'e massa muscolare senza accumulare troppa fatica.';
    } else if (volumeChange > -5) {
      return 'Volume stabile rispetto alla settimana precedente. Perfetto per consolidare i progressi '
             'o per una fase di mantenimento.';
    } else if (volumeChange > -20) {
      return 'Leggera riduzione del volume. Può essere utile per favorire il recupero '
             'mantenendo comunque lo stimolo allenante.';
    } else {
      return 'Significativa riduzione del volume. Se pianificata (deload week), ottimo per il recupero. '
             'Altrimenti, valuta se ci sono fattori esterni che influenzano il tuo allenamento.';
    }
  }

  String _getIntensityExplanation() {
    final rpe = 6 + (avgIntensity - 1) * 4 / 9;
    if (rpe >= 9) {
      return 'Intensità molto alta! Stai lavorando vicino al massimale. '
             'Assicurati di non mantenere questa intensità per troppe settimane consecutive.';
    } else if (rpe >= 7.5) {
      return 'Intensità ottimale per costruire forza e massa. '
             'Stai lasciando 2-3 ripetizioni in riserva, perfetto per progressi sostenibili.';
    } else if (rpe >= 6.5) {
      return 'Intensità moderata, ideale per volume alto o fase di apprendimento tecnico. '
             "Puoi aumentare gradualmente l'intensità se ti senti recuperato.";
    } else {
      return 'Intensità bassa, utile per recupero attivo o perfezionamento tecnico. '
             'Se non è una settimana di scarico, considera di aumentare i carichi.';
    }
  }

  String _getRecoveryExplanation() {
    if (avgFatigue < 2) {
      return "Recupero eccellente! Il tuo corpo risponde molto bene all'allenamento. "
             'Potresti anche aumentare volume o frequenza se desideri.';
    } else if (avgFatigue < 3) {
      return 'Buon recupero con fatica gestibile. Questo è il range ideale per progressi '
             'costanti senza rischio di sovrallenamento.';
    } else if (avgFatigue < 4) {
      return 'Fatica accumulata moderata. Monitora attentamente i prossimi allenamenti '
             'e considera di ridurre volume o intensità se peggiora.';
    } else {
      return 'Fatica elevata! Il tuo corpo ha bisogno di più recupero. '
             'Considera 2-3 giorni di riposo completo o una settimana di scarico.';
    }
  }

  String _getFrequencyExplanation() {
    if (workoutCount >= 6) {
      return "Frequenza molto alta! Assicurati di variare l'intensità tra le sessioni "
             'e di includere giorni più leggeri per favorire il recupero.';
    } else if (workoutCount >= 4) {
      return 'Frequenza ottimale per la maggior parte degli atleti intermedi/avanzati. '
             'Permette buon volume settimanale con recupero adeguato.';
    } else if (workoutCount >= 3) {
      return 'Frequenza standard, ideale per principianti/intermedi o per chi ha tempo limitato. '
             'Focus sulla qualità degli allenamenti piuttosto che sulla quantità.';
    } else {
      return 'Frequenza bassa. Se è il tuo standard, assicurati che ogni sessione '
             'sia sufficientemente stimolante. Altrimenti, cerca di aumentare gradualmente.';
    }
  }

  Color _getIntensityColor() {
    final rpe = 6 + (avgIntensity - 1) * 4 / 9;
    if (rpe >= 9) return Colors.red;
    if (rpe >= 7.5) return Colors.orange;
    if (rpe >= 6.5) return Colors.blue;
    return Colors.grey;
  }

  Color _getFatigueColor() {
    if (avgFatigue < 2) return Colors.green;
    if (avgFatigue < 3) return Colors.blue;
    if (avgFatigue < 4) return Colors.orange;
    return Colors.red;
  }
}

enum AdviceCategory {
  pushHard,
  maintainPace,
  beCareful,
  takeRest,
  recovery,
}

class ContextualAdvice {

  ContextualAdvice({
    required this.mainMessage,
    this.subMessage,
    this.subIcon,
  });
  final String mainMessage;
  final String? subMessage;
  final IconData? subIcon;
}