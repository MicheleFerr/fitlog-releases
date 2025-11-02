import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class WelcomeStep extends StatefulWidget {

  const WelcomeStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  State<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<WelcomeStep>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _textController;
  late AnimationController _featureController;
  late Animation<double> _heroScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late List<Animation<double>> _featureAnimations;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _featureController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _heroScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.elasticOut,
    ));

    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _featureAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _featureController,
        curve: Interval(
          index * 0.2,
          0.8 + (index * 0.05),
          curve: Curves.easeOutBack,
        ),
      ));
    });

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    unawaited(_heroController.forward());

    await Future.delayed(const Duration(milliseconds: 600));
    unawaited(_textController.forward());

    await Future.delayed(const Duration(milliseconds: 400));
    unawaited(_featureController.forward());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _textController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40), // Top padding per centrare visivamente
          // Hero icon with animation
          AnimatedBuilder(
            animation: _heroController,
            builder: (context, child) {
              return Transform.scale(
                scale: _heroScale.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                        colorScheme.tertiary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: colorScheme.onPrimary,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // Title and description with animation
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      Text(
                        l10n.onboardingWelcomeTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        l10n.onboardingWelcomeDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 18,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 56),

          // Feature highlights with staggered animation
          Text(
            l10n.onboardingWhatToExpect,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 32),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.3),
                      colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.onboardingWelcomeMissionTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.onboardingWelcomeMission,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildAnimatedFeature(
                0,
                Icons.psychology,
                l10n.onboardingWelcomeFeature1Title,
                l10n.onboardingWelcomeFeature1Description,
                colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _buildAnimatedFeature(
                1,
                Icons.tune,
                l10n.onboardingWelcomeFeature2Title,
                l10n.onboardingWelcomeFeature2Description,
                colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _buildAnimatedFeature(
                2,
                Icons.fitness_center,
                l10n.onboardingWelcomeFeature3Title,
                l10n.onboardingWelcomeFeature3Description,
                colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              _buildAnimatedFeature(
                3,
                Icons.rocket_launch,
                l10n.onboardingWelcomeFeature4Title,
                l10n.onboardingWelcomeFeature4Description,
                context.colors.secondary,
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Call to action
          AnimatedBuilder(
            animation: _featureController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _featureAnimations[3],
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.3),
                        colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.onboardingWelcomeCallToAction,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 60), // Bottom padding per scrolling completo
        ],
      ),
    );
  }

  Widget _buildAnimatedFeature(
    int index,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _featureController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _featureAnimations[index].value)),
          child: Opacity(
            opacity: _featureAnimations[index].value,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
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
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}