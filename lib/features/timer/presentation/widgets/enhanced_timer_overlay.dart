import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../providers/timer_provider.dart';
import '../providers/timer_settings_provider.dart';
import '../providers/timer_position_provider.dart';
import '../../domain/entities/rest_timer.dart';
import '../../domain/entities/timer_position.dart';

/// Timer overlay migliorato con trascinamento libero e auto-recovery
class EnhancedTimerOverlay extends ConsumerStatefulWidget {
  const EnhancedTimerOverlay({super.key});

  @override
  ConsumerState<EnhancedTimerOverlay> createState() => _EnhancedTimerOverlayState();
}

/// ✅ RECOVERY FAB - Mostra FAB se timer è poco visibile
class TimerRecoveryFAB extends ConsumerWidget {
  const TimerRecoveryFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(currentTimerProvider);
    final settings = ref.watch(timerDisplaySettingsProvider);
    
    if (timer == null || !timer.isActive) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final timerSize = TimerPositionHelper.getSizeForMode(settings.displayMode);
    
    // Controlla se timer è ben visibile (almeno 70% del widget)
    final isWellVisible = _isTimerWellVisible(settings.position, screenSize, timerSize);
    
    if (isWellVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100, // Sopra il FAB principale
      right: 16,
      child: FloatingActionButton.small(
        heroTag: "timer_recovery", // Evita conflitti hero
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => _recoverTimer(ref, screenSize),
        child: const Icon(Icons.access_time, size: 20),
      ),
    );
  }

  bool _isTimerWellVisible(Offset position, Size screenSize, Size timerSize) {
    // Calcola quanto del timer è visibile
    final timerRect = Rect.fromLTWH(position.dx, position.dy, timerSize.width, timerSize.height);
    final screenRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    final visibleRect = timerRect.intersect(screenRect);
    
    if (visibleRect.isEmpty) return false;
    
    final timerArea = timerSize.width * timerSize.height;
    final visibleArea = visibleRect.width * visibleRect.height;
    
    return (visibleArea / timerArea) >= 0.7; // 70% visible
  }

  void _recoverTimer(WidgetRef ref, Size screenSize) {
    // Posiziona timer al centro dello schermo
    final timerSize = TimerPositionHelper.getSizeForMode(TimerDisplayMode.normal);
    final centerPosition = Offset(
      (screenSize.width - timerSize.width) / 2,
      (screenSize.height - timerSize.height) / 2,
    );
    
    ref.read(timerDisplaySettingsProvider.notifier).updatePosition(centerPosition);
    ref.read(timerDisplaySettingsProvider.notifier).changeDisplayMode(TimerDisplayMode.normal);
  }
}

class _EnhancedTimerOverlayState extends ConsumerState<EnhancedTimerOverlay> 
    with TickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _snapAnimationController;
  late Animation<Offset> _snapAnimation;
  
  @override
  void initState() {
    super.initState();
    _snapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _snapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(currentTimerProvider);
    final settings = ref.watch(timerDisplaySettingsProvider);
    
    // Non mostrare se timer non attivo o nascosto
    if (timer == null || !timer.isActive || !settings.isVisible) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final timerSize = TimerPositionHelper.getSizeForMode(settings.displayMode);

    // ✅ AUTO-RECOVERY: Valida e corregge posizione se fuori schermo
    final positionProvider = ref.read(timerPositionProvider.notifier);
    final validatedPosition = positionProvider.constrainToScreen(
      settings.position, 
      screenSize, 
      timerSize,
      MediaQuery.of(context).padding,
    );
    
    // Aggiorna posizione se era fuori schermo
    if (validatedPosition != settings.position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timerDisplaySettingsProvider.notifier).updatePosition(validatedPosition);
      });
    }

    return Positioned(
      left: validatedPosition.dx,
      top: validatedPosition.dy,
      child: GestureDetector(
        onDoubleTap: () => _handleDoubleTap(ref),
        onPanStart: _handlePanStart,
        onPanUpdate: (details) => _handlePanUpdate(details, ref, screenSize, timerSize),
        onPanEnd: _handlePanEnd,
        child: Material(
          elevation: _isDragging ? 12 : 8,
          borderRadius: BorderRadius.circular(
            settings.displayMode == TimerDisplayMode.compact ? 25 : 16,
          ),
          child: Transform.scale(
            scale: _isDragging ? 1.05 : 1.0,
            child: Container(
              width: timerSize.width,
              height: timerSize.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  settings.displayMode == TimerDisplayMode.compact ? 25 : 16,
                ),
                gradient: LinearGradient(
                  colors: _getGradientColors(timer, context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildTimerContent(context, ref, timer, settings),
            ),
          ),
        ),
      ),
    );
  }

  /// Gestisce il doppio tap per toggle modalità compatta
  void _handleDoubleTap(WidgetRef ref) {
    ref.read(timerDisplaySettingsProvider.notifier).toggleCompactMode();
    HapticFeedback.mediumImpact();
  }

  /// Gestisce l'inizio del trascinamento
  void _handlePanStart(DragStartDetails details) {
    // Interrompi l'animazione di snap se in corso
    if (_snapAnimationController.isAnimating) {
      _snapAnimationController.stop();
      _snapAnimationController.reset();
    }
    
    setState(() {
      _isDragging = true;
    });
    HapticFeedback.lightImpact();
  }

  /// Gestisce l'aggiornamento del trascinamento
  void _handlePanUpdate(DragUpdateDetails details, WidgetRef ref, Size screenSize, Size timerSize) {
    // Non aggiornare se c'è un'animazione di snap in corso
    if (_snapAnimationController.isAnimating) {
      return;
    }
    
    final settings = ref.read(timerDisplaySettingsProvider);
    final newPosition = settings.position + details.delta;
    
    // ✅ Usa il sistema avanzato che mantiene sempre 48px visibili
    final positionProvider = ref.read(timerPositionProvider.notifier);
    final constrainedPosition = positionProvider.constrainToScreen(
      newPosition, 
      screenSize, 
      timerSize,
      MediaQuery.of(context).padding,
    );
    
    ref.read(timerDisplaySettingsProvider.notifier).updatePosition(constrainedPosition);
  }

  /// Gestisce la fine del trascinamento con snap-to-edges
  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    final settings = ref.read(timerDisplaySettingsProvider);
    final screenSize = MediaQuery.of(context).size;
    final timerSize = TimerPositionHelper.getSizeForMode(settings.displayMode);
    final currentPosition = settings.position;
    
    // Calcola il bordo più vicino
    final snapPosition = _calculateSnapPosition(currentPosition, screenSize, timerSize);
    
    // Se la posizione è diversa, anima verso il bordo
    if ((snapPosition - currentPosition).distance > 10) {
      _animateToPosition(currentPosition, snapPosition);
      
      // Feedback aptico diverso per angoli vs bordi
      final isCornerSnap = _isCornerPosition(snapPosition, screenSize, timerSize);
      if (isCornerSnap) {
        HapticFeedback.heavyImpact(); // Feedback più forte per angoli
      } else {
        HapticFeedback.mediumImpact(); // Feedback normale per bordi
      }
    } else {
      HapticFeedback.lightImpact(); // Feedback leggero se non c'è snap
    }
  }

  /// Calcola la posizione di snap al bordo più vicino (inclusi angoli)
  Offset _calculateSnapPosition(Offset currentPosition, Size screenSize, Size timerSize) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // Margini dai bordi
    const edgeMargin = 8.0;
    const cornerThreshold = 80.0; // Distanza massima per snap agli angoli
    
    // Posizioni degli angoli
    final topLeft = Offset(edgeMargin, safeAreaTop + edgeMargin);
    final topRight = Offset(screenSize.width - timerSize.width - edgeMargin, safeAreaTop + edgeMargin);
    final bottomLeft = Offset(edgeMargin, screenSize.height - timerSize.height - safeAreaBottom - edgeMargin);
    final bottomRight = Offset(screenSize.width - timerSize.width - edgeMargin, screenSize.height - timerSize.height - safeAreaBottom - edgeMargin);
    
    // Calcola distanze agli angoli
    final distanceToTopLeft = (currentPosition - topLeft).distance;
    final distanceToTopRight = (currentPosition - topRight).distance;
    final distanceToBottomLeft = (currentPosition - bottomLeft).distance;
    final distanceToBottomRight = (currentPosition - bottomRight).distance;
    
    // Trova l'angolo più vicino se è abbastanza vicino
    final minCornerDistance = [
      distanceToTopLeft, 
      distanceToTopRight, 
      distanceToBottomLeft, 
      distanceToBottomRight
    ].reduce((a, b) => a < b ? a : b);
    
    if (minCornerDistance <= cornerThreshold) {
      if (minCornerDistance == distanceToTopLeft) {
        return topLeft;
      } else if (minCornerDistance == distanceToTopRight) {
        return topRight;
      } else if (minCornerDistance == distanceToBottomLeft) {
        return bottomLeft;
      } else {
        return bottomRight;
      }
    }
    
    // Se non vicino a un angolo, snap ai bordi
    final leftEdge = Offset(edgeMargin, currentPosition.dy);
    final rightEdge = Offset(screenSize.width - timerSize.width - edgeMargin, currentPosition.dy);
    final topEdge = Offset(currentPosition.dx, safeAreaTop + edgeMargin);
    final bottomEdge = Offset(currentPosition.dx, screenSize.height - timerSize.height - safeAreaBottom - edgeMargin);
    
    // Calcola le distanze verso ogni bordo
    final distanceToLeft = (currentPosition - leftEdge).distance;
    final distanceToRight = (currentPosition - rightEdge).distance;
    final distanceToTop = (currentPosition - topEdge).distance;
    final distanceToBottom = (currentPosition - bottomEdge).distance;
    
    // Trova il bordo più vicino
    final minDistance = [distanceToLeft, distanceToRight, distanceToTop, distanceToBottom].reduce((a, b) => a < b ? a : b);
    
    if (minDistance == distanceToLeft) {
      return _constrainPosition(leftEdge, screenSize, timerSize);
    } else if (minDistance == distanceToRight) {
      return _constrainPosition(rightEdge, screenSize, timerSize);
    } else if (minDistance == distanceToTop) {
      return _constrainPosition(topEdge, screenSize, timerSize);
    } else {
      return _constrainPosition(bottomEdge, screenSize, timerSize);
    }
  }

  /// Vincola la posizione ai limiti dello schermo
  Offset _constrainPosition(Offset position, Size screenSize, Size timerSize) {
    // ✅ Usa il sistema avanzato che mantiene sempre 48px visibili
    final positionProvider = ref.read(timerPositionProvider.notifier);
    return positionProvider.constrainToScreen(
      position, 
      screenSize, 
      timerSize,
      MediaQuery.of(context).padding,
    );
  }

  /// Verifica se una posizione è in un angolo
  bool _isCornerPosition(Offset position, Size screenSize, Size timerSize) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    const edgeMargin = 8.0;
    const cornerTolerance = 20.0;
    
    // Posizioni degli angoli
    final topLeft = Offset(edgeMargin, safeAreaTop + edgeMargin);
    final topRight = Offset(screenSize.width - timerSize.width - edgeMargin, safeAreaTop + edgeMargin);
    final bottomLeft = Offset(edgeMargin, screenSize.height - timerSize.height - safeAreaBottom - edgeMargin);
    final bottomRight = Offset(screenSize.width - timerSize.width - edgeMargin, screenSize.height - timerSize.height - safeAreaBottom - edgeMargin);
    
    return (position - topLeft).distance <= cornerTolerance ||
           (position - topRight).distance <= cornerTolerance ||
           (position - bottomLeft).distance <= cornerTolerance ||
           (position - bottomRight).distance <= cornerTolerance;
  }

  /// Anima il timer verso la posizione di destinazione
  void _animateToPosition(Offset startPosition, Offset endPosition) async {
    // Reset l'animazione se era già in corso
    _snapAnimationController.reset();
    
    _snapAnimation = Tween<Offset>(
      begin: startPosition,
      end: endPosition,
    ).animate(CurvedAnimation(
      parent: _snapAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Listener unico per l'animazione
    void animationListener() {
      if (_snapAnimationController.isAnimating) {
        ref.read(timerDisplaySettingsProvider.notifier).updatePosition(_snapAnimation.value);
      }
    }

    _snapAnimationController.addListener(animationListener);

    try {
      await _snapAnimationController.forward();
      // Rimuovi il listener e assicurati che la posizione finale sia impostata
      _snapAnimationController.removeListener(animationListener);
      
      // Imposta la posizione finale e forza il salvataggio
      await ref.read(timerDisplaySettingsProvider.notifier).updatePosition(endPosition);
      
      _snapAnimationController.reset();
    } catch (e) {
      // Cleanup in caso di errore
      _snapAnimationController.removeListener(animationListener);
      _snapAnimationController.reset();
    }
  }

  /// Costruisce il contenuto del timer basato sulla modalità
  Widget _buildTimerContent(
    BuildContext context, 
    WidgetRef ref, 
    RestTimer timer, 
    TimerDisplaySettingsExtended settings,
  ) {
    return Padding(
      padding: EdgeInsets.all(settings.displayMode == TimerDisplayMode.compact ? 8 : 12),
      child: settings.displayMode == TimerDisplayMode.compact
          ? _buildCompactContent(context, timer, settings)
          : _buildNormalContent(context, ref, timer, settings),
    );
  }

  /// Contenuto in modalità compatta
  Widget _buildCompactContent(BuildContext context, RestTimer timer, TimerDisplaySettingsExtended settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicatore di stato
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(timer),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        
        // Tempo rimanente
        Text(
          timer.formattedTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  /// Contenuto in modalità normale (quello esistente)
  Widget _buildNormalContent(
    BuildContext context, 
    WidgetRef ref, 
    RestTimer timer,
    TimerDisplaySettingsExtended settings,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con exercise info
        Row(
          children: [
            Icon(
              _getTimerIcon(timer.status),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rest Timer',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (timer.exerciseName != null)
                    Text(
                      timer.exerciseName!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (timer.currentSet != null && timer.totalSets != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Set ${timer.currentSet}/${timer.totalSets}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            
            // Pulsante per toggle modalità compatta
            _TimerActionButton(
              icon: Icons.compress,
              onPressed: () => ref.read(timerDisplaySettingsProvider.notifier).toggleCompactMode(),
              tooltip: 'Modalità compatta',
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Timer display con progress ring
        Row(
          children: [
            // Progress ring
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  // Background circle
                  CustomPaint(
                    size: const Size(50, 50),
                    painter: ProgressRingPainter(
                      progress: 0.0,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      progressColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle
                  CustomPaint(
                    size: const Size(50, 50),
                    painter: ProgressRingPainter(
                      progress: timer.progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.transparent,
                      progressColor: Colors.white,
                    ),
                  ),
                  // Timer icon in center
                  Center(
                    child: Icon(
                      timer.isPaused ? Icons.pause : Icons.timer,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Time display and controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time remaining
                  Text(
                    timer.formattedTime,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status text
                  Text(
                    _getStatusText(timer),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Control buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add time button
                _TimerActionButton(
                  icon: Icons.add,
                  onPressed: () => ref.read(currentTimerProvider.notifier).addTime(30),
                  tooltip: '+30s',
                ),
                const SizedBox(width: 8),
                // Pause/Resume button
                _TimerActionButton(
                  icon: timer.isPaused ? Icons.play_arrow : Icons.pause,
                  onPressed: () {
                    if (timer.isPaused) {
                      ref.read(currentTimerProvider.notifier).resumeTimer();
                    } else {
                      ref.read(currentTimerProvider.notifier).pauseTimer();
                    }
                  },
                  tooltip: timer.isPaused ? 'Resume' : 'Pause',
                ),
                const SizedBox(width: 8),
                // Skip button
                _TimerActionButton(
                  icon: Icons.skip_next,
                  onPressed: () => ref.read(currentTimerProvider.notifier).skipTimer(),
                  tooltip: 'Skip',
                ),
              ],
            ),
          ],
        ),
        
        // Progress bar
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: timer.progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }

  /// Ottiene il colore di stato per il timer compatto
  Color _getStatusColor(RestTimer timer) {
    if (timer.isCompleted) return Colors.green;
    if (timer.isPaused) return Colors.orange;
    if (timer.remainingSeconds <= 30) return Colors.red;
    if (timer.remainingSeconds <= 60) return Colors.orange;
    return Colors.blue;
  }

  /// Ottiene i colori del gradiente (riutilizzato dal widget originale)
  List<Color> _getGradientColors(RestTimer timer, BuildContext context) {
    if (timer.isCompleted) {
      return [Colors.green.shade600, Colors.green.shade800];
    } else if (timer.isPaused) {
      return [Colors.orange.shade600, Colors.orange.shade800];
    } else if (timer.remainingSeconds <= 30) {
      return [Colors.red.shade600, Colors.red.shade800];
    } else if (timer.remainingSeconds <= 60) {
      return [Colors.orange.shade600, Colors.orange.shade800];
    } else {
      return [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withRed(
          (Theme.of(context).colorScheme.primary.red * 0.8).round(),
        ),
      ];
    }
  }

  IconData _getTimerIcon(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return Icons.timer;
      case TimerStatus.paused:
        return Icons.pause_circle;
      case TimerStatus.completed:
        return Icons.check_circle;
      case TimerStatus.idle:
        return Icons.timer_outlined;
      case TimerStatus.awaitingRPE:
        return Icons.star_rate;
    }
  }

  String _getStatusText(RestTimer timer) {
    if (timer.isCompleted) {
      return 'Rest complete! Ready for next set';
    } else if (timer.isPaused) {
      return 'Timer paused';
    } else if (timer.remainingSeconds <= 30) {
      return 'Get ready...';
    } else {
      return 'Rest time';
    }
  }
}


/// Pulsante azione del timer (riutilizzato dal widget originale)
class _TimerActionButton extends StatelessWidget {
  const _TimerActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter per progress ring (riutilizzato dal widget originale)
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    if (progressColor != Colors.transparent && progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor;
  }
}