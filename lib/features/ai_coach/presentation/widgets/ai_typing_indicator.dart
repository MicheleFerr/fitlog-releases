/// AI Typing Indicator Widget
///
/// Animated dots showing AI is processing.
/// Staggered animation with 0.2s delay between dots for smooth effect.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Typing indicator widget
class AITypingIndicator extends StatefulWidget {
  const AITypingIndicator({super.key});

  @override
  State<AITypingIndicator> createState() => _AITypingIndicatorState();
}

class _AITypingIndicatorState extends State<AITypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Create 3 staggered animations
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start animations with 200ms delay
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + (_animations[index].value * 0.7),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 8, height: 8),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'AI sta scrivendo...',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
