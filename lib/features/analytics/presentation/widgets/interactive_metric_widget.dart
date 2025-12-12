import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget interattivo che mostra una metrica con tooltip esplicativo
class InteractiveMetricWidget extends StatelessWidget {

  const InteractiveMetricWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.beginnerExplanation,
    required this.intermediateExplanation,
    required this.advancedExplanation,
    this.formula,
    this.customContent,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String beginnerExplanation;
  final String intermediateExplanation;
  final String advancedExplanation;
  final String? formula;
  final Widget? customContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _showExplanationDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: customContent ?? Column(
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
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5,
),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
          ],
        ),
      ),
    );
  }

  void _showExplanationDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExplanationSheet(
        title: title,
        value: value,
        icon: icon,
        color: color,
        beginnerExplanation: beginnerExplanation,
        intermediateExplanation: intermediateExplanation,
        advancedExplanation: advancedExplanation,
        formula: formula,
      ),
    );
  }
}

class _ExplanationSheet extends StatefulWidget {

  const _ExplanationSheet({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.beginnerExplanation,
    required this.intermediateExplanation,
    required this.advancedExplanation,
    this.formula,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String beginnerExplanation;
  final String intermediateExplanation;
  final String advancedExplanation;
  final String? formula;

  @override
  State<_ExplanationSheet> createState() => _ExplanationSheetState();
}

class _ExplanationSheetState extends State<_ExplanationSheet> {
  int _selectedLevel = 0; // 0: Beginner, 1: Intermediate, 2: Advanced

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: safeMax,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Current: ${widget.value}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: widget.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Level Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildLevelTab('Principiante', 0, theme),
                        _buildLevelTab('Intermedio', 1, theme),
                        _buildLevelTab('Avanzato', 2, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Explanation based on level
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildExplanation(theme),
                    ),
                    
                    // Formula if available
                    if (widget.formula != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  AppIcons.functions,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Formula',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.formula!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Practical Examples
                    const SizedBox(height: 24),
                    _buildPracticalExamples(theme),
                    
                    // Tips
                    const SizedBox(height: 24),
                    _buildTips(theme),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTab(String label, int index, ThemeData theme) {
    final isSelected = _selectedLevel == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedLevel = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(ThemeData theme) {
    String explanation;
    IconData levelIcon;
    Color levelColor;
    
    switch (_selectedLevel) {
      case 0:
        explanation = widget.beginnerExplanation;
        levelIcon = AppIcons.rocketLaunch;
        levelColor = context.colors.success;
        break;
      case 1:
        explanation = widget.intermediateExplanation;
        levelIcon = AppIcons.fitnessCenter;
        levelColor = context.colors.secondary;
        break;
      case 2:
        explanation = widget.advancedExplanation;
        levelIcon = AppIcons.emojiEvents;
        levelColor = context.colors.error;
        break;
      default:
        explanation = widget.beginnerExplanation;
        levelIcon = AppIcons.rocketLaunch;
        levelColor = context.colors.success;
    }
    
    return Container(
      key: ValueKey(_selectedLevel),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(levelIcon, color: levelColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Spiegazione',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticalExamples(ThemeData theme) {
    final examples = _getExamplesForLevel();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.tip,
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Esempi Pratici',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: Text(
                    example,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTips(ThemeData theme) {
    final tips = _getTipsForLevel();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.1),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.tipsAndUpdates,
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Consigli',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tips,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getExamplesForLevel() {
    switch (widget.title.toLowerCase()) {
      case 'total volume':
      case 'volume totale':
        switch (_selectedLevel) {
          case 0:
            return [
              '10 kg x 10 reps = 100 kg di volume',
              '3 set da 100 kg = 300 kg totali',
              'Obiettivo principiante: 5000-10000 kg/settimana',
            ];
          case 1:
            return [
              'Panca: 80kg x 10 x 4 = 3200 kg',
              'Squat: 100kg x 8 x 5 = 4000 kg',
              'Obiettivo intermedio: 15000-25000 kg/settimana',
            ];
          case 2:
            return [
              'Volume ondulato: Settimana pesante 30000kg, leggera 18000kg',
              'Mesociclo: Accumulo → Intensificazione → Realizzazione',
              'Obiettivo avanzato: 25000-40000 kg/settimana',
            ];
          default:
            return [];
        }
      
      case 'effective volume':
      case 'volume efficace':
        switch (_selectedLevel) {
          case 0:
            return [
              'Solo i set con sforzo contano (RPE ≥ 6)',
              'Riscaldamento non conta nel volume efficace',
              'Focus sulla qualità, non quantità',
            ];
          case 1:
            return [
              'Set a RPE 7-8 = 85% efficacia',
              'Set a RPE 9-10 = 100% efficacia',
              'Obiettivo: 70-80% del volume totale sia efficace',
            ];
          case 2:
            return [
              'MRV (Maximum Recoverable Volume) personalizzato',
              'Volume efficace per gruppo muscolare',
              'Autoregolazione basata su recupero',
            ];
          default:
            return [];
        }
        
      default:
        return ['Esempio generico per ${widget.title}'];
    }
  }

  String _getTipsForLevel() {
    switch (_selectedLevel) {
      case 0:
        return 'Inizia con carichi leggeri e concentrati sulla tecnica. '
               'Il volume aumenterà naturalmente man mano che migliori. '
               'Non confrontarti con altri, segui il tuo percorso!';
      case 1:
        return 'Monitora i progressi settimanali. Un aumento del 2-5% '
               'del volume è sostenibile. Alterna settimane pesanti e leggere '
               'per favorire il recupero e l\'adattamento.';
      case 2:
        return 'Periodizza il tuo allenamento in mesocicli. Usa tecniche '
               'avanzate come cluster sets, rest-pause e drop sets strategicamente. '
               'Il recupero diventa cruciale quanto l\'allenamento stesso.';
      default:
        return '';
    }
  }
}
