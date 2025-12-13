import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// A widget that overlays a blur effect on premium features for free users
class PremiumFeatureOverlay extends StatelessWidget {
  
  const PremiumFeatureOverlay({
    super.key,
    required this.isPremium,
    required this.featureName,
    required this.child,
    this.height = 300,
  });
  final bool isPremium;
  final String featureName;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // If user is premium, show the feature without any overlay
    if (isPremium) {
      return child;
    }
    
    // For free users, show blurred content with overlay
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The actual content, slightly visible through blur
          IgnorePointer(
            ignoring: true,
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 8.0,
                  sigmaY: 8.0,
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.surface.withValues(alpha: 0.3),
                    BlendMode.srcOver,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
          
          // Overlay with lock icon and text
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to premium purchase screen
                context.push(AppRoutes.premiumPath);
              },
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.1),
                      theme.colorScheme.surface.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: SemanticIcon(
  icon: AppIcons.lockOutline,
  semanticLabel: 'Lock outline',
  size: AppIconSize.medium,
  color: theme.colorScheme.primary,
),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Premium Feature',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featureName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.star,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Unlock Premium',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
