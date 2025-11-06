/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: shared
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS-first design with spring animations
///
/// FAB espandibile con animazioni fluide in stile Apple HIG
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Opzione per il FAB espandibile
class ExpandableFabOption {
  const ExpandableFabOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

class ExpandableFAB extends StatefulWidget {
  const ExpandableFAB({
    super.key,
    required this.icon,
    required this.label,
    required this.options,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final List<ExpandableFabOption> options;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _contentController;
  late AnimationController _bounceController;
  late Animation<double> _morphAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  bool _isExpanded = false;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Controller principale per la trasformazione (via di mezzo)
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Controller per il contenuto interno (sincronizzato)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Controller per l'effetto bounce finale (più veloce e bouncy)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Animazione principale con curve bilanciate
    final balancedCurve = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInQuart,
    );

    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(balancedCurve);

    // Bounce animation più pronunciato e vivace
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08, // Aumentato per più bounce
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Contenuto che appare con timing bilanciato
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );

    // Blur per lo sfondo bilanciato
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0, // Bilanciato
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutQuart,
    ));

    // Scale per l'effetto di preparazione bilanciato
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93, // Bilanciato
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
    ));

    // Glow animation bilanciata
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _morphController.dispose();
    _contentController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _toggle() {
    // Haptic feedback per il tap
    HapticFeedback.lightImpact();

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      // Apertura: animazione principale seguita da bounce
      _morphController.forward().then((_) {
        // Bounce finale quando l'animazione principale è completata
        _bounceController.forward().then((_) {
          // Ritorno alla dimensione normale dopo il bounce
          _bounceController.reverse();
        });
      });
      _contentController.forward();
    } else {
      // Chiusura: animazione speculare fluida
      _bounceController.reset();
      _morphController.reverse();
      _contentController.reverse();
    }
  }

  void _onOptionTap(ExpandableFabOption option) {
    HapticFeedback.mediumImpact();

    // Prima chiudi l'animazione
    _toggle();

    // Poi esegui l'azione dopo la chiusura completa (timing bilanciato)
    Future.delayed(const Duration(milliseconds: 900), () {
      option.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background con blur effect quando espanso
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedBuilder(
                animation: _blurAnimation,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2 * _morphAnimation.value),
                    ),
                  );
                },
              ),
            ),
          ),

        // Il FAB che si trasforma in dialog
        AnimatedBuilder(
          animation: _morphAnimation,
          builder: (context, child) {
            // Calcola le dimensioni target per il dialog
            final dialogWidth = size.width * 0.85;
            const dialogHeight = 320.0;

            // Posizione iniziale del FAB (basso-destra)
            const fabWidth = 180.0;
            const fabHeight = 56.0;
            final fabStartX = size.width - fabWidth - 16; // 16px di padding dal bordo
            final fabStartY = size.height - fabHeight - 16; // 16px di padding dal bordo

            // Calcola la posizione target per il dialog (centro-basso)
            final targetX = (size.width - dialogWidth) / 2;
            final targetY = size.height - dialogHeight - 120;

            // Interpola dimensioni tra FAB e dialog
            final currentWidth = lerpDouble(
              fabWidth,
              dialogWidth,
              _morphAnimation.value,
            )!;

            final currentHeight = lerpDouble(
              fabHeight,
              dialogHeight,
              _morphAnimation.value,
            )!;

            final currentRadius = lerpDouble(
              28,
              24,
              _morphAnimation.value,
            )!;

            // Posizione animata: FAB (destra) -> Dialog (centro)
            final currentX = lerpDouble(
              fabStartX,
              targetX,
              _morphAnimation.value,
            )!;

            final currentY = lerpDouble(
              fabStartY,
              targetY,
              _morphAnimation.value,
            )!;

            // Effetto bounce applicato alla scala
            final bounceScale = _isExpanded
                ? _bounceAnimation.value
                : _scaleAnimation.value;

            return Positioned(
              left: currentX,
              top: currentY,
              child: Transform.scale(
                scale: bounceScale,
                child: Container(
                  key: _isExpanded ? null : _fabKey,
                  width: currentWidth,
                  height: currentHeight,
                  decoration: BoxDecoration(
                    // Gradiente radiale per effetto bolla organica
                    gradient: _isExpanded
                        ? RadialGradient(
                            center: const Alignment(-0.3, -0.4),
                            radius: 1.2,
                            colors: [
                              colorScheme.surface.withValues(alpha: 0.95),
                              colorScheme.surface.withValues(alpha: 0.85),
                              colorScheme.surfaceContainerHigh,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (widget.backgroundColor ?? colorScheme.primary),
                              (widget.backgroundColor ?? colorScheme.primary).withValues(alpha: 0.9),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(currentRadius),
                    border: _isExpanded
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.1 * _glowAnimation.value),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      // Ombra principale
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: lerpDouble(8, 24, _morphAnimation.value)!,
                        offset: Offset(0, lerpDouble(4, 12, _morphAnimation.value)!),
                        spreadRadius: lerpDouble(0, 2, _morphAnimation.value)!,
                      ),
                      // Ombra secondaria per profondità
                      if (_isExpanded) BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      // Effetto glow quando espanso
                      if (_isExpanded) BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.15 * _glowAnimation.value),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isExpanded ? null : _toggle,
                      borderRadius: BorderRadius.circular(currentRadius),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(currentRadius),
                        child: Stack(
                          children: [
                            // Glassmorphism effect quando espanso
                            if (_isExpanded)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 3.0 * _glowAnimation.value,
                                        sigmaY: 3.0 * _glowAnimation.value,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(currentRadius),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.1 * _glowAnimation.value),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            // Contenuto del FAB (icona + label)
                            if (!_isExpanded || _morphAnimation.value < 0.3)
                              Opacity(
                                opacity: 1 - (_morphAnimation.value * 3).clamp(0, 1),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.icon,
                                          color: widget.foregroundColor ?? colorScheme.onPrimary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            widget.label,
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: widget.foregroundColor ?? colorScheme.onPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Contenuto del dialog (opzioni)
                            if (_isExpanded)
                              AnimatedBuilder(
                                animation: _contentAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _contentAnimation.value,
                                    child: Transform.scale(
                                      scale: 0.9 + (_contentAnimation.value * 0.1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Titolo
                                            Text(
                                              widget.label,
                                              style: theme.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 32),
                                            // Opzioni
                                            ...widget.options.map((option) =>
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: _buildOptionButton(option),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // Pulsante chiusura quando espanso
                            if (_isExpanded)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: AnimatedBuilder(
                                  animation: _contentAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _contentAnimation.value,
                                      child: IconButton(
                                        onPressed: _toggle,
                                        icon: Icon(
                                          AppIcons.close,
                                          color: colorScheme.onSurface,
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionButton(ExpandableFabOption option) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () => _onOptionTap(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              size: 24,
              color: colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              option.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
