import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ModeSelectionWithTogglesStep extends ConsumerStatefulWidget {

  const ModeSelectionWithTogglesStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  ConsumerState<ModeSelectionWithTogglesStep> createState() => _ModeSelectionWithTogglesStepState();
}

class _ModeSelectionWithTogglesStepState extends ConsumerState<ModeSelectionWithTogglesStep>
    with SingleTickerProviderStateMixin {
  bool? _selectedMode; // true = Pro, false = Base
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectMode(bool isProMode) {
    setState(() {
      _selectedMode = isProMode;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Save selection to onboarding state
    ref.read(onboardingStateProvider.notifier).saveStepData(
      'selectedMode',
      isProMode,
    );

    // Apply settings immediately for preview
    ref.read(appConfigProvider.notifier).updateWorkoutSettings(
      isProMode: isProMode,
      rpeTracking: isProMode,
      autoRestTimer: true,
      setDurationTracking: isProMode,
      plateCalculator: isProMode,
      warmupSuggestions: isProMode,
      autoCollapseCompleted: !isProMode,
    );

    ref.read(appConfigProvider.notifier).updateDisplaySettings(
      showTutInfo: isProMode,
      showExerciseNotes: true,
      showCommunitySuggestions: isProMode,
      showExerciseInsights: isProMode,
      showCustomTimers: isProMode,
      showAdvancedMenu: isProMode,
      showCollapseCountdown: !isProMode,
      simplifiedAnimations: !isProMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        children: [
          // Title
          Text(
            l10n.onboardingModeTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            l10n.onboardingModeInfluenceDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Mode cards
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Base Mode
                  ScaleTransition(
                    scale: _selectedMode == false ? _scaleAnimation :
                          const AlwaysStoppedAnimation(1.0),
                    child: _buildModeCard(
                      context,
                      title: l10n.onboardingBaseMode,
                      description: l10n.onboardingBaseModeDescription,
                      icon: AppIcons.playArrowRounded,
                      isSelected: _selectedMode == false,
                      onTap: () => _selectMode(false),
                      features: [
                        '✓ Tracciamento serie e ripetizioni',
                        '✓ Timer di riposo automatico',
                        '✓ Template salvabili',
                        '✓ Interfaccia semplificata',
                        '✓ Auto-collapse completati',
                        '✗ RPE e analisi avanzate',
                        '✗ Suggerimenti community',
                        '✗ Insights dettagliati',
                      ],
                      color: colorScheme.secondary,
                      togglesEnabled: [
                        'Timer automatico',
                        'Note esercizi',
                        'Auto-collapse',
                        'Animazioni semplificate',
                      ],
                      togglesDisabled: [
                        'Tracciamento RPE',
                        'Suggerimenti community',
                        'Menu avanzati',
                        'Insights dettagliati',
                        'Timer personalizzati',
                        'Informazioni TUT',
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pro Mode
                  ScaleTransition(
                    scale: _selectedMode == true ? _scaleAnimation :
                          const AlwaysStoppedAnimation(1.0),
                    child: _buildModeCard(
                      context,
                      title: l10n.onboardingProMode,
                      description: l10n.onboardingProModeDescription,
                      icon: Icons.stars_rounded,
                      isSelected: _selectedMode == true,
                      onTap: () => _selectMode(true),
                      features: [
                        '✓ Tutto della modalità Base',
                        '✓ Tracciamento RPE dettagliato',
                        '✓ Informazioni TUT',
                        '✓ Analisi e insights avanzati',
                        '✓ Suggerimenti community',
                        '✓ Menu personalizzazioni complete',
                        '✓ Timer personalizzabili',
                        '✓ Warmup suggestions',
                      ],
                      color: colorScheme.primary,
                      isPremium: true,
                      togglesEnabled: [
                        'Tutti i toggle disponibili',
                        'Tracciamento RPE',
                        'Informazioni TUT',
                        'Suggerimenti community',
                        'Menu avanzati',
                        'Timer personalizzati',
                        'Insights dettagliati',
                        'Warmup suggestions',
                      ],
                      togglesDisabled: [
                        'Auto-collapse (opzionale)',
                        'Animazioni semplificate (opzionale)',
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info footer
          if (_selectedMode != null) ...[
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value,
                    child: Container(
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
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.toggleSettingsHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required List<String> features,
    required Color color,
    bool isPremium = false,
    required List<String> togglesEnabled,
    required List<String> togglesDisabled,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.tertiary,
                                    colorScheme.tertiary.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PRO',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onTertiary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 24,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Features
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    feature.startsWith('✓') ? Icons.check : Icons.close,
                    color: feature.startsWith('✓') ? color : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.substring(2), // Remove ✓ or ✗
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: feature.startsWith('✓')
                            ? colorScheme.onSurface.withValues(alpha: 0.8)
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            )),

            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Toggle preview
              Text(
                'Toggle Attivi:',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...togglesEnabled.map((toggle) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    Icon(Icons.toggle_on, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        toggle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              if (togglesDisabled.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Toggle Disattivi:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...togglesDisabled.map((toggle) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      const Icon(Icons.toggle_off, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          toggle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ],
        ),
      ),
    );
  }
}