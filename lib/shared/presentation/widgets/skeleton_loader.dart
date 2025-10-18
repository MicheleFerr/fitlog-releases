/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Skeleton loaders riutilizzabili per stati di caricamento
library;

import 'package:flutter/material.dart';

/// Skeleton loader generico con animazione pulse
class SkeletonLoader extends StatefulWidget {

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (isDark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surfaceContainerHigh)
                .withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

/// Skeleton loader per card statistiche
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(8),
                ),
                const Spacer(),
                SkeletonLoader(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonLoader(
              width: 80,
              height: 12,
            ),
            const SizedBox(height: 8),
            const SkeletonLoader(
              width: 120,
              height: 32,
            ),
            const SizedBox(height: 8),
            const SkeletonLoader(
              width: 60,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader per grafici/charts
class ChartSkeleton extends StatelessWidget {

  const ChartSkeleton({
    super.key,
    this.height = 200,
    this.showLegend = false,
  });
  final double height;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const SkeletonLoader(
              width: 150,
              height: 20,
            ),
            const SizedBox(height: 16),

            // Chart area
            SkeletonLoader(
              width: double.infinity,
              height: height,
              borderRadius: BorderRadius.circular(12),
            ),

            // Legend (se richiesta)
            if (showLegend) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(),
                  const SizedBox(width: 16),
                  _buildLegendItem(),
                  const SizedBox(width: 16),
                  _buildLegendItem(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonLoader(
          width: 16,
          height: 16,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        SizedBox(width: 8),
        SkeletonLoader(
          width: 60,
          height: 12,
        ),
      ],
    );
  }
}

/// Skeleton loader per lista di workout recenti
class WorkoutListSkeleton extends StatelessWidget {

  const WorkoutListSkeleton({
    super.key,
    this.itemCount = 3,
  });
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SkeletonLoader(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(
                          width: 150,
                          height: 16,
                        ),
                        SizedBox(height: 8),
                        SkeletonLoader(
                          width: 100,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                  const SkeletonLoader(
                    width: 60,
                    height: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader per griglia di metriche
class MetricGridSkeleton extends StatelessWidget {

  const MetricGridSkeleton({
    super.key,
    this.itemCount = 4,
  });
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: List.generate(
        itemCount,
        (index) => const StatCardSkeleton(),
      ),
    );
  }
}

/// Skeleton loader per muscle balance/heatmap
class MuscleBalanceSkeleton extends StatelessWidget {
  const MuscleBalanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(
              width: 180,
              height: 20,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(
                      6,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SkeletonLoader(
                              width: 80,
                              height: 12,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: SkeletonLoader(
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader per hero card
class HeroCardSkeleton extends StatelessWidget {
  const HeroCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              width: 120,
              height: 16,
            ),
            SizedBox(height: 12),
            SkeletonLoader(
              width: 200,
              height: 40,
            ),
            Spacer(),
            SkeletonLoader(
              width: 100,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
