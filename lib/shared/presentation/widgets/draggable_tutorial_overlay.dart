/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// Tutorial overlay per spiegare il drag del FAB
library;

import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class DraggableTutorialOverlay extends StatefulWidget {
  
  const DraggableTutorialOverlay({
    super.key,
    required this.child,
    required this.tutorialKey,
  });
  final Widget child;
  final String tutorialKey;
  
  @override
  State<DraggableTutorialOverlay> createState() => _DraggableTutorialOverlayState();
}

class _DraggableTutorialOverlayState extends State<DraggableTutorialOverlay> 
    with SingleTickerProviderStateMixin {
  bool _showTutorial = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _checkFirstTime();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('draggable_tutorial_${widget.tutorialKey}') ?? false;
    
    if (!hasSeenTutorial && mounted) {
      setState(() {
        _showTutorial = true;
      });
      _animationController.forward();
      
      // Auto-nascondi dopo 5 secondi
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _dismissTutorial();
        }
      });
    }
  }
  
  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('draggable_tutorial_${widget.tutorialKey}', true);
    
    await _animationController.reverse();
    if (mounted) {
      setState(() {
        _showTutorial = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Stack(
      children: [
        widget.child,
        
        // 🔧 PERFORMANCE FIX: Use FadeTransition (GPU-accelerated) instead of Opacity
        if (_showTutorial)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  );
                },
                // 🔧 PERFORMANCE FIX: Use child parameter to avoid rebuilding static content
                child: GestureDetector(
                  onTap: _dismissTutorial,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.onSurface.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.swipe,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Drag to Move',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Swipe the button left or right to change its position',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _dismissTutorial,
                          icon: Icon(
                            AppIcons.close,
                            size: 18,
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}