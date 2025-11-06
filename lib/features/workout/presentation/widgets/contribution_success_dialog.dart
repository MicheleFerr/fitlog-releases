/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: dialog
/// 🌍 Localization: ✅ Full support
/// 🎨 Theme: ✅ Adaptive
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/animated_xp_bar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ContributionSuccessDialog extends ConsumerStatefulWidget {

  const ContributionSuccessDialog({
    super.key,
    required this.contributionType,
    required this.onViewContribution,
    required this.onClose,
  });
  final ContributionType contributionType;
  final VoidCallback onViewContribution;
  final VoidCallback onClose;

  @override
  ConsumerState<ContributionSuccessDialog> createState() => _ContributionSuccessDialogState();
}

class _ContributionSuccessDialogState extends ConsumerState<ContributionSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _xpController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _xpAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _xpController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOutCubic,
    );
    
    _xpAnimation = CurvedAnimation(
      parent: _xpController,
      curve: Curves.bounceOut,
    );
    
    // Start animations in sequence
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _xpController.forward();
      HapticFeedback.lightImpact();
    });
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _xpController.dispose();
    super.dispose();
  }
  
  String _getContributionText() {
    switch (widget.contributionType) {
      case ContributionType.correction:
        return 'Correzione Inviata!';
      case ContributionType.tip:
        return 'Consiglio Inviato!';
      case ContributionType.warning:
        return 'Avviso Inviato!';
      case ContributionType.variant:
        return 'Variante Inviata!';
      case ContributionType.translation:
        return 'Traduzione Inviata!';
      case ContributionType.technique:
        return 'Tecnica Inviata!';
    }
  }
  
  int _getXPValue() {
    // Con auto-approvazione ottieni submitContribution (10) + contributionApproved (50) = 60 XP
    // Mostriamo il totale che l'utente riceverà
    return 60; // Total XP con auto-approvazione
  }
  
  String _getXPAmount() {
    return '+${_getXPValue()} XP';
  }
  
  IconData _getIcon() {
    switch (widget.contributionType) {
      case ContributionType.correction:
        return AppIcons.edit;
      case ContributionType.tip:
        return AppIcons.lightbulb;
      case ContributionType.warning:
        return AppIcons.warning;
      case ContributionType.variant:
        return AppIcons.tune;
      case ContributionType.translation:
        return AppIcons.translate;
      case ContributionType.technique:
        return AppIcons.sportsGymnastics;
    }
  }
  
  Color _getColor() {
    switch (widget.contributionType) {
      case ContributionType.correction:
        return context.colors.primary;
      case ContributionType.tip:
        return context.colors.success;
      case ContributionType.warning:
        return context.colors.secondary;
      case ContributionType.variant:
        return context.colors.tertiary;
      case ContributionType.translation:
        return Colors.teal;
      case ContributionType.technique:
        return Colors.indigo;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = _getColor();
    
    // Get user stats for XP calculation - use .select() to watch only totalPoints
    final previousXP = ref.watch(
      userContributionStatsProvider.select((stats) => stats.valueOrNull?.totalPoints ?? 0),
    );
    final xpGained = _getXPValue();
    final currentXP = previousXP + xpGained;
    final currentLevel = (currentXP / 500).floor() + 1;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: context.screenHeight * 0.9,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with success animation
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.1),
                        color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Success Icon with Animation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.2),
                                  color.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _checkAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _checkAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [color, color.withValues(alpha: 0.8)],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: context.colors.surface,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        _getContributionText(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Text(
                        'La community ti ringrazia! 🙏',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Animated XP Bar
                AnimatedBuilder(
                  animation: _xpAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _xpAnimation.value),
                      child: Opacity(
                        opacity: _xpAnimation.value,
                        child: AnimatedXPBar(
                          currentXP: currentXP,
                          previousXP: previousXP,
                          xpGained: xpGained,
                          currentLevel: currentLevel,
                          onAnimationComplete: () {
                            // Auto close after animation completes
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                widget.onClose();
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onViewContribution,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('I Miei Contributi'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.onClose,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Fantastico!'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// Modal per visualizzare i consigli della community
