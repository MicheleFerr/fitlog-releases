import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Skeleton loader widget for workout history items
/// Shows animated placeholder while loading real data
class WorkoutSkeletonLoader extends StatelessWidget {
  
  const WorkoutSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = context.colors.surfaceContainerHighest;
    final highlightColor = isDark
        ? HSLColor.fromColor(baseColor).withLightness(0.15).toColor()
        : HSLColor.fromColor(baseColor).withLightness(0.95).toColor();

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildSkeletonItem(context),
      ),
    );
  }
  
  Widget _buildSkeletonItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date placeholder
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          
          // Workout name placeholder
          Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          
          // Exercise count placeholder
          Row(
            children: [
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loading indicator for pagination
class LoadMoreIndicator extends StatelessWidget {
  
  const LoadMoreIndicator({
    super.key,
    this.message = 'Loading more workouts...',
  });
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator(),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}