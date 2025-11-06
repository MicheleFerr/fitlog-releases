/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class BuddyActionButtons extends StatefulWidget {

  const BuddyActionButtons({
    super.key,
    this.onDislike,
    this.onLike,
    this.onSuperLike,
    this.isEnabled = true,
  });
  final VoidCallback? onDislike;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;
  final bool isEnabled;

  @override
  State<BuddyActionButtons> createState() => _BuddyActionButtonsState();
}

class _BuddyActionButtonsState extends State<BuddyActionButtons>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  String? _pressedButton;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dislike button
          _buildActionButton(
            context: context,
            theme: theme,
            icon: AppIcons.close,
            label: l10n.pass,
            color: context.colors.error,
            size: 60,
            onPressed: widget.isEnabled ? () => _handleButtonPress('dislike', widget.onDislike) : null,
            buttonId: 'dislike',
          ),

          // Super like button (smaller)
          _buildActionButton(
            context: context,
            theme: theme,
            icon: AppIcons.star,
            label: l10n.superLike,
            color: context.colors.primary,
            size: 45,
            onPressed: widget.isEnabled ? () => _handleButtonPress('superlike', widget.onSuperLike) : null,
            buttonId: 'superlike',
          ),

          // Like button
          _buildActionButton(
            context: context,
            theme: theme,
            icon: AppIcons.favorite,
            label: l10n.like,
            color: context.colors.success,
            size: 70,
            onPressed: widget.isEnabled ? () => _handleButtonPress('like', widget.onLike) : null,
            buttonId: 'like',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    required VoidCallback? onPressed,
    required String buttonId,
  }) {
    final isPressed = _pressedButton == buttonId;
    final isDisabled = !widget.isEnabled || onPressed == null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isPressed ? _scaleAnimation.value : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDisabled 
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                      : color,
                  boxShadow: isDisabled ? null : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(size / 2),
                    onTap: onPressed,
                    onTapDown: (_) {
                      if (onPressed != null) {
                        setState(() {
                          _pressedButton = buttonId;
                        });
                        _scaleController.forward();
                      }
                    },
                    onTapUp: (_) {
                      _resetButtonState();
                    },
                    onTapCancel: () {
                      _resetButtonState();
                    },
                    child: Center(
                      child: Icon(
                        icon,
                        color: isDisabled 
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                            : context.colors.surface,
                        size: size * 0.4,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Label
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDisabled 
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleButtonPress(String buttonId, VoidCallback? callback) {
    if (callback == null) return;

    // Haptic feedback based on button type
    switch (buttonId) {
      case 'dislike':
        HapticFeedback.lightImpact();
        break;
      case 'like':
        HapticFeedback.mediumImpact();
        break;
      case 'superlike':
        HapticFeedback.heavyImpact();
        break;
    }

    callback();
  }

  void _resetButtonState() {
    setState(() {
      _pressedButton = null;
    });
    _scaleController.reverse();
  }
}
