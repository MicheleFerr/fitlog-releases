/// AI Typing Indicator Widget
///
/// Animated dots with progressive status messages and fun facts.
/// Shows time-aware phases while AI processes the request:
/// - 0-5s: "Analizzo i tuoi dati..."
/// - 5-12s: "Calcolo le tue progressioni..."
/// - 12-20s: "Preparo la risposta..."
/// - 20s+: Random fun facts, rotating every 10s
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Fun facts fitness displayed during long AI waits
const _funFacts = [
  'Il muscolo più forte del corpo è il massetere (la mascella)',
  'I muscoli rappresentano circa il 40% del peso corporeo',
  'Il cuore batte circa 100.000 volte al giorno',
  'Un passo coinvolge circa 200 muscoli diversi',
  'Le ossa sono 5 volte più resistenti dell\'acciaio a parità di peso',
  'Il corpo umano ha oltre 600 muscoli',
  'I muscoli possono contrarsi fino a 50 volte al secondo',
  'Camminare 1 km brucia circa 60-70 calorie',
  'Il muscolo più lungo del corpo è il sartorio nella coscia',
  'Sorridere richiede 17 muscoli, fare il broncio 43',
  'I tendini possono sopportare fino a 5 volte il peso corporeo',
  'Il gluteo massimo è il muscolo più grande del corpo',
  'Durante una vita il cuore pompa circa 200 milioni di litri di sangue',
  'Il corpo produce circa 300 miliardi di nuove cellule ogni giorno',
  'La forza di presa media di un uomo è circa 45 kg',
];

/// Typing indicator widget with progressive status messages
class AITypingIndicator extends StatefulWidget {
  const AITypingIndicator({super.key});

  @override
  State<AITypingIndicator> createState() => _AITypingIndicatorState();
}

class _AITypingIndicatorState extends State<AITypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  int _currentFactIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentFactIndex = Random().nextInt(_funFacts.length);

    // Create 3 staggered dot animations
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

    // Start dot animations with 200ms delay
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }

    // Start elapsed timer
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        // Rotate fun fact every 10s after the 20s mark
        if (_elapsedSeconds >= 20 && (_elapsedSeconds - 20) % 10 == 0) {
          _currentFactIndex = (_currentFactIndex + 1) % _funFacts.length;
        }
      });
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  ({IconData icon, String text}) _currentPhase() {
    if (_elapsedSeconds < 5) {
      return (icon: AppIcons.search, text: 'Analizzo i tuoi dati...');
    } else if (_elapsedSeconds < 12) {
      return (
        icon: AppIcons.trendingUp,
        text: 'Calcolo le tue progressioni...',
      );
    } else if (_elapsedSeconds < 20) {
      return (icon: AppIcons.edit, text: 'Preparo la risposta...');
    } else {
      return (
        icon: AppIcons.lightbulb,
        text: 'Lo sapevi? ${_funFacts[_currentFactIndex]}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = _currentPhase();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dots row
          Row(
            children: List.generate(3, (index) {
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
          ),
          const SizedBox(height: AppSpacing.xs),
          // Progressive status text with icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: Row(
              key: ValueKey(phase.text),
              children: [
                Icon(
                  phase.icon,
                  size: 14,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    phase.text,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
