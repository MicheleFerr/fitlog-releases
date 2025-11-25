import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';

/// Quick Start Screen - First screen shown to new users
/// Allows them to choose between beginner (guided) or expert (self-explore) path
class QuickStartScreen extends ConsumerStatefulWidget {
  const QuickStartScreen({super.key});

  @override
  ConsumerState<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends ConsumerState<QuickStartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedLevel; // 'beginner' | 'expert'

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_selectedLevel == null) return;

    final onboardingNotifier = ref.read(onboardingStateProvider.notifier);
    await onboardingNotifier.completeQuickStart(_selectedLevel!);

    if (mounted) {
      // Navigate to home screen (router will handle showing appropriate empty state)
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _onSkip() async {
    if (mounted) {
      // Skip to home without setting experience level
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Skip button (top right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        l10n.quickStartSkip,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hero icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primary,
                          colors.secondary,
                          colors.tertiary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      AppIcons.workout,
                      size: AppIconSize.xxlarge,
                      color: colors.onPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    l10n.quickStartTitle,
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    l10n.quickStartSubtitle,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Question
                  Text(
                    l10n.quickStartQuestion,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Question description
                  Text(
                    l10n.quickStartQuestionDescription,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Beginner option
                  _ExperienceLevelCard(
                    isSelected: _selectedLevel == 'beginner',
                    onTap: () => setState(() => _selectedLevel = 'beginner'),
                    icon: AppIcons.beginner,
                    title: l10n.quickStartBeginner,
                    description: l10n.quickStartBeginnerDescription,
                    color: context.colors.success,
                  ),

                  const SizedBox(height: 16),

                  // Expert option
                  _ExperienceLevelCard(
                    isSelected: _selectedLevel == 'expert',
                    onTap: () => setState(() => _selectedLevel = 'expert'),
                    icon: AppIcons.expert,
                    title: l10n.quickStartExpert,
                    description: l10n.quickStartExpertDescription,
                    color: colors.primary,
                  ),

                  const Spacer(),

                  // Continue button
                  AnimatedOpacity(
                    opacity: _selectedLevel != null ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedLevel != null ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: _selectedLevel != null ? 4 : 0,
                        ),
                        child: Text(
                          l10n.quickStartContinue,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperienceLevelCard extends StatelessWidget {
  const _ExperienceLevelCard({
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colors.outline.withValues(alpha: 0.3),
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: AppIconSize.large,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark (if selected)
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.check,
                  size: AppIconSize.small,
                  color: colors.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
