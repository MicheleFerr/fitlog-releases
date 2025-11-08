import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class TogglePanoramaStep extends ConsumerStatefulWidget {

  const TogglePanoramaStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  ConsumerState<TogglePanoramaStep> createState() => _TogglePanoramaStepState();
}

class _TogglePanoramaStepState extends ConsumerState<TogglePanoramaStep>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late List<Animation<double>> _itemAnimations;
  late ScrollController _scrollController;
  int _expandedCategoryIndex = -1;

  List<ToggleCategory> _getToggleCategories(AppLocalizations l10n) => [
    ToggleCategory(
      title: l10n.onboardingToggleAdvancedTrackingTitle,
      description: l10n.onboardingToggleAdvancedTrackingDescription,
      icon: AppIcons.analytics,
      color: Colors.blue,
      toggles: [
        ToggleInfo(
          name: 'Tracciamento RPE',
          description: 'Valuta l\'intensità percepita (Rate of Perceived Exertion) per ogni serie',
          configKey: 'rpeTracking',
          isPro: true,
          example: 'RPE 8/10 = Serie molto intensa ma non a cedimento',
        ),
        ToggleInfo(
          name: 'Insights Esercizi',
          description: 'Mostra statistiche e analisi sui tuoi progressi',
          configKey: 'showExerciseInsights',
          isPro: true,
          example: 'Volume +15% rispetto alla settimana scorsa',
        ),
      ],
    ),
    ToggleCategory(
      title: l10n.onboardingToggleTimerAutomationTitle,
      description: l10n.onboardingToggleTimerAutomationDescription,
      icon: AppIcons.timer,
      color: Colors.green,
      toggles: [
        ToggleInfo(
          name: 'Timer Automatico',
          description: 'Avvia automaticamente il timer di riposo dopo ogni serie',
          configKey: 'autoRestTimer',
          isPro: false,
          example: 'Completi una serie → Timer parte automaticamente',
        ),
        ToggleInfo(
          name: 'Timer Personalizzati',
          description: 'Mostra opzioni per timer personalizzati per ogni esercizio (disponibile per tutti)',
          configKey: 'showCustomTimers',
          isPro: false,
          example: 'Squat: 3min, Bicep curl: 90s, Cardio: 30s',
        ),
        ToggleInfo(
          name: 'Auto-Collapse Completati',
          description: 'Comprimi automaticamente gli esercizi completati',
          configKey: 'autoCollapseCompleted',
          isPro: false,
          example: 'Esercizio completato → Si comprime dopo 2 secondi',
        ),
        ToggleInfo(
          name: 'Countdown Collapse',
          description: 'Mostra il countdown prima del collasso automatico',
          configKey: 'showCollapseCountdown',
          isPro: false,
          example: 'Collasso in: 3... 2... 1...',
        ),
      ],
    ),
    ToggleCategory(
      title: l10n.onboardingToggleInterfaceTitle,
      description: l10n.onboardingToggleInterfaceDescription,
      icon: AppIcons.tune,
      color: Colors.purple,
      toggles: [
        ToggleInfo(
          name: 'Informazioni TUT',
          description: 'Mostra consigli sul Time Under Tension',
          configKey: 'showTutInfo',
          isPro: true,
          example: '💡 Rallenta la fase eccentrica per più guadagni',
        ),
        ToggleInfo(
          name: 'Note Esercizi',
          description: 'Sezione per aggiungere note personalizzate',
          configKey: 'showExerciseNotes',
          isPro: false,
          example: '📝 "Aumentare peso la prossima volta"',
        ),
        ToggleInfo(
          name: 'Suggerimenti Community',
          description: 'Consigli e tips dalla community GymBro',
          configKey: 'showCommunitySuggestions',
          isPro: true,
          example: '👥 "Prova le pause rest-pause per più intensità"',
        ),
        ToggleInfo(
          name: 'Menu Avanzati',
          description: 'Mostra opzioni avanzate nei menu',
          configKey: 'showAdvancedMenu',
          isPro: true,
          example: 'Superset, Dropset, Rest-Pause, 1-Rep Max',
        ),
        ToggleInfo(
          name: 'Animazioni Semplificate',
          description: 'Riduce le animazioni per migliorare le performance',
          configKey: 'simplifiedAnimations',
          isPro: false,
          example: 'Transizioni più veloci e meno effetti grafici',
        ),
      ],
    ),
    ToggleCategory(
      title: l10n.onboardingToggleSupportTitle,
      description: l10n.onboardingToggleSupportDescription,
      icon: AppIcons.supportAgent,
      color: Colors.orange,
      toggles: [
        ToggleInfo(
          name: 'Warmup Suggestions',
          description: 'Suggerimenti per il riscaldamento prima degli esercizi',
          configKey: 'warmupSuggestions',
          isPro: true,
          example: '🔥 "Inizia con 50% del peso per 8-10 ripetizioni"',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Temporarily use a fixed number for initialization
    _itemAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _listController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutBack,
        ),
      ));
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _listController.forward();
      }
    });
  }

  void _scrollToExpandedItem(int index) {
    if (!_scrollController.hasClients) return;

    // Calculate the position to scroll to
    // Each category card has approximately 80px + margins
    const double categoryHeight = 100.0;
    const double headerHeight = 150.0; // Approximate header height

    final double targetPosition = headerHeight + (index * categoryHeight) - 50;

    _scrollController.animateTo(
      targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final isProMode = config.isProMode ?? false;
    final toggleCategories = _getToggleCategories(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Header
          Text(
            AppLocalizations.of(context).onboardingTogglePanoramaTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Description - hidden when any category is expanded
          AnimatedCrossFade(
            firstChild: Column(
              children: [
                Text(
                  AppLocalizations.of(context).onboardingTogglePanoramaDescription,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
            secondChild: const SizedBox(height: 8),
            crossFadeState: _expandedCategoryIndex == -1
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),

          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isProMode
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isProMode
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Modalità attuale: ${isProMode ? 'Pro' : 'Base'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isProMode
                    ? colorScheme.primary
                    : colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Categories list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: toggleCategories.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _listController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _itemAnimations[index].value)),
                      child: Opacity(
                        opacity: _itemAnimations[index].value,
                        child: _buildCategoryCard(index, theme, colorScheme, config, toggleCategories),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Footer tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.tip,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: l10n.onboardingToggleSettingsChangePart1),
                        const TextSpan(text: ' '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.moreVert,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.onboardingToggleSettingsChangePart2,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(int index, ThemeData theme, ColorScheme colorScheme, config, List<ToggleCategory> toggleCategories) {
    final category = toggleCategories[index];
    final isExpanded = _expandedCategoryIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category header
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategoryIndex = isExpanded ? -1 : index;
              });

              // Scroll to keep the expanded content visible
              if (!isExpanded && index != -1) {
                Future.delayed(const Duration(milliseconds: 350), () {
                  _scrollToExpandedItem(index);
                });
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Column(
                    children: category.toggles.map((toggle) =>
                        _buildToggleItem(toggle, theme, colorScheme, config)
                    ).toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(ToggleInfo toggle, ThemeData theme, ColorScheme colorScheme, config) {
    final isEnabled = _getToggleValue(toggle.configKey, config);
    final isProMode = config.isProMode ?? false;
    final isAvailable = !toggle.isPro || isProMode;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable
            ? (isEnabled
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3))
            : colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? (isEnabled
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2))
              : colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Toggle status icon
              Icon(
                isAvailable
                    ? (isEnabled ? AppIcons.toggleOn : AppIcons.toggleOff)
                    : AppIcons.lock,
                color: isAvailable
                    ? (isEnabled ? colorScheme.primary : Colors.grey)
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  toggle.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isAvailable
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (toggle.isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PRO',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            toggle.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isAvailable
                  ? colorScheme.onSurface.withValues(alpha: 0.8)
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (toggle.example != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.tip,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      toggle.example!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
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

  bool _getToggleValue(String configKey, config) {
    switch (configKey) {
      case 'rpeTracking': return config.rpeTracking ?? false;
      case 'autoRestTimer': return config.autoRestTimer ?? true;
      case 'setDurationTracking': return config.setDurationTracking ?? false;
      case 'warmupSuggestions': return config.warmupSuggestions ?? false;
      case 'autoCollapseCompleted': return config.autoCollapseCompleted ?? false;
      case 'showTutInfo': return config.showTutInfo ?? false;
      case 'showExerciseNotes': return config.showExerciseNotes ?? true;
      case 'showCommunitySuggestions': return config.showCommunitySuggestions ?? false;
      case 'showExerciseInsights': return config.showExerciseInsights ?? false;
      case 'showCustomTimers': return config.showCustomTimers ?? false;
      case 'showAdvancedMenu': return config.showAdvancedMenu ?? false;
      case 'showCollapseCountdown': return config.showCollapseCountdown ?? false;
      case 'simplifiedAnimations': return config.simplifiedAnimations ?? false;
      default: return false;
    }
  }
}

class ToggleCategory {

  ToggleCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.toggles,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<ToggleInfo> toggles;
}

class ToggleInfo {

  ToggleInfo({
    required this.name,
    required this.description,
    required this.configKey,
    required this.isPro,
    this.example,
  });
  final String name;
  final String description;
  final String configKey;
  final bool isPro;
  final String? example;
}
