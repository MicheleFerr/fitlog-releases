import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class RadialContributionMenu extends StatefulWidget {
  
  const RadialContributionMenu({
    super.key,
    required this.onTip,
    required this.onWarning,
    required this.onCorrection,
    required this.onTechnique,
    required this.onClose,
  });
  final VoidCallback onTip;
  final VoidCallback onWarning;
  final VoidCallback onCorrection;
  final VoidCallback onTechnique;
  final VoidCallback onClose;

  @override
  State<RadialContributionMenu> createState() => _RadialContributionMenuState();
}

class _RadialContributionMenuState extends State<RadialContributionMenu>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _itemAnimations;
  
  final List<_MenuItem> _menuItems = [];
  
  @override
  void initState() {
    super.initState();
    
    _menuItems.addAll([
      _MenuItem(
        icon: Icons.lightbulb,
        label: 'Consiglio',
        color: context.colors.warning,
        onTap: widget.onTip,
      ),
      _MenuItem(
        icon: AppIcons.warningAmberRounded,
        label: 'Avviso',
        color: context.colors.secondary,
        onTap: widget.onWarning,
      ),
      _MenuItem(
        icon: AppIcons.editNote,
        label: 'Correzione',
        color: context.colors.primary,
        onTap: widget.onCorrection,
      ),
      _MenuItem(
        icon: Icons.fitness_center,
        label: 'Tecnica',
        color: context.colors.tertiary,
        onTap: widget.onTechnique,
      ),
    ]);
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _itemAnimations = List.generate(
      _menuItems.length,
      (index) {
        final angle = (index * 2 * math.pi) / _menuItems.length - math.pi / 2;
        const radius = 100.0;
        return Tween<Offset>(
          begin: Offset.zero,
          end: Offset(
            math.cos(angle) * radius / 100,
            math.sin(angle) * radius / 100,
          ),
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.6 + index * 0.1,
            curve: Curves.elasticOut,
          ),
        ));
      },
    );
    
    _controller.forward();
    _rotationController.repeat();
    
    HapticFeedback.mediumImpact();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  void _handleItemTap(VoidCallback onTap) {
    HapticFeedback.lightImpact();
    _controller.reverse().then((_) {
      onTap();
      widget.onClose();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          _controller.reverse().then((_) {
            widget.onClose();
          });
        },
        child: Container(
          color: context.colors.onSurface.withValues(alpha: 0.5),
          child: Stack(
            children: [
              // Backdrop blur effect
              FadeTransition(
                opacity: _fadeAnimation,
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    context.colors.onSurface.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                  child: Container(),
                ),
              ),
              
              // Center glow effect
              Center(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Center button
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _controller.reverse().then((_) {
                          widget.onClose();
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: context.colors.surface,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Menu items
              ...List.generate(_menuItems.length, (index) {
                final item = _menuItems[index];
                return Center(
                  child: AnimatedBuilder(
                    animation: _itemAnimations[index],
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: _itemAnimations[index].value,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _RadialMenuItem(
                            item: item,
                            onTap: () => _handleItemTap(item.onTap),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              
              // Title
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Contribuisci alla Community',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: context.colors.surface,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: context.colors.onSurface.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialMenuItem extends StatefulWidget {
  
  const _RadialMenuItem({
    required this.item,
    required this.onTap,
  });
  final _MenuItem item;
  final VoidCallback onTap;
  
  @override
  State<_RadialMenuItem> createState() => _RadialMenuItemState();
}

class _RadialMenuItemState extends State<_RadialMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutBack,
    ));
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isHovered = true;
          _hoverController.forward();
        });
      },
      onTapUp: (_) {
        setState(() {
          _isHovered = false;
          _hoverController.reverse();
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _isHovered = false;
          _hoverController.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: widget.item.color.withValues(alpha: _isHovered ? 0.6 : 0.3),
                    blurRadius: _isHovered ? 25 : 15,
                    spreadRadius: _isHovered ? 3 : 1,
                  ),
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: widget.item.color.withValues(alpha: _isHovered ? 0.8 : 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.item.icon,
                    color: widget.item.color,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.item.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  
  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

// Helper function to show the radial menu
void showRadialContributionMenu({
  required BuildContext context,
  required VoidCallback onTip,
  required VoidCallback onWarning,
  required VoidCallback onCorrection,
  required VoidCallback onTechnique,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => RadialContributionMenu(
      onTip: onTip,
      onWarning: onWarning,
      onCorrection: onCorrection,
      onTechnique: onTechnique,
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}