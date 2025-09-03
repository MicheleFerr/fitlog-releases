import 'package:flutter/material.dart';

/// Large hero card for displaying primary metrics
class HeroStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Widget? chart;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final IconData? icon;
  
  const HeroStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.chart,
    this.gradientColors = const [],
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors.isNotEmpty 
        ? gradientColors
        : [theme.colorScheme.primary, theme.colorScheme.secondary];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon ?? Icons.show_chart,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Value
                    Text(
                      value,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    // Chart or additional content
                    if (chart != null) 
                      Expanded(
                        child: chart!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}