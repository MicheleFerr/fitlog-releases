/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: shared
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Draggable action button con salvataggio posizione
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Opzione aggiuntiva per il menu del long press
class DraggableActionOption {
  
  const DraggableActionOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
}

class DraggableActionButton extends StatefulWidget { // Opzioni aggiuntive nel menu
  
  const DraggableActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.positionKey,
    this.backgroundColor,
    this.foregroundColor,
    this.onShowHistory,
    this.additionalOptions,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String positionKey; // Chiave unica per salvare la posizione
  final VoidCallback? onShowHistory; // Callback per mostrare lo storico
  final List<DraggableActionOption>? additionalOptions;
  
  @override
  State<DraggableActionButton> createState() => _DraggableActionButtonState();
}

class _DraggableActionButtonState extends State<DraggableActionButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  
  double _currentX = 0;
  double _dragStartX = 0;
  bool _isDragging = false;
  bool _isOnLeft = false;
  
  // Soglie per snap
  static const double _snapThreshold = 0.5;
  static const double _edgePadding = 16.0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadPosition();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getString('fab_position_${widget.positionKey}');
    
    if (savedPosition == 'left') {
      setState(() {
        _isOnLeft = true;
      });
    }
  }
  
  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'fab_position_${widget.positionKey}', 
      _isOnLeft ? 'left' : 'right'
    );
  }
  
  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartX = details.localPosition.dx;
    });
    HapticFeedback.lightImpact();
  }
  
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentX = details.localPosition.dx - _dragStartX;
    });
  }
  
  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    const buttonWidth = 180.0; // Larghezza stimata del button
    final centerX = (screenWidth - buttonWidth) / 2;
    
    // Calcola se siamo più vicini a sinistra o destra
    final absoluteX = _isOnLeft 
        ? _currentX 
        : (screenWidth - buttonWidth - _edgePadding) + _currentX;
    
    final shouldSnapLeft = absoluteX < centerX;
    
    setState(() {
      _isDragging = false;
      _isOnLeft = shouldSnapLeft;
      _currentX = 0;
    });
    
    // Haptic feedback per lo snap
    HapticFeedback.mediumImpact();
    
    // Salva la nuova posizione
    _savePosition();
    
    // Anima il ritorno alla posizione
    _animationController.forward(from: 0).then((_) {
      _animationController.reset();
    });
  }
  
  void _showOptionsMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Opzione principale (azione normale)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(widget.label),
              subtitle: const Text('Azione principale'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onPressed();
              },
            ),
            
            // Opzione storico se disponibile
            if (widget.onShowHistory != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.history,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: const Text('Storico'),
                subtitle: const Text('Visualizza workout precedenti'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onShowHistory!();
                },
              ),
            
            // Opzioni aggiuntive se presenti
            if (widget.additionalOptions != null)
              ...widget.additionalOptions!.map((option) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (option.color ?? Theme.of(context).colorScheme.tertiary).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    option.icon,
                    color: option.color ?? Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                title: Text(option.label),
                onTap: () {
                  Navigator.of(context).pop();
                  option.onTap();
                },
              )),
            
            // Informazione drag
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  SemanticIcon(
  icon: AppIcons.swipe,
  semanticLabel: 'Swipe',
  size: AppIconSize.small,
  color: Theme.of(context,
).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trascina il pulsante per spostarlo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calcola la posizione base (sinistra o destra)
    final double baseX = _isOnLeft 
        ? _edgePadding 
        : screenWidth - 180 - _edgePadding; // 180 è la larghezza stimata
    
    // Aggiungi l'offset del drag
    double currentX = baseX + (_isDragging ? _currentX : 0);
    
    // Limita il movimento ai bordi dello schermo
    currentX = currentX.clamp(_edgePadding, screenWidth - 180 - _edgePadding);
    
    return Positioned(
      bottom: 16,
      left: currentX,
      child: AnimatedContainer(
        duration: _isDragging 
            ? Duration.zero 
            : const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Stack(
          children: [
            // Button principale con gesture detector
            GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onLongPress: () {
                // Mostra menu opzioni
                _showOptionsMenu(context);
              },
              child: AbsorbPointer(
                absorbing: _isDragging, // Disabilita tap durante drag
                child: PremiumActionButton(
                  onPressed: widget.onPressed,
                  icon: widget.icon,
                  label: widget.label,
                  backgroundColor: widget.backgroundColor,
                  foregroundColor: widget.foregroundColor,
                  showShadow: !_isDragging,
                  width: 160,
                ),
              ),
            ),
              
              // Indicatore di drag (appare solo durante il trascinamento)
              if (_isDragging)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              
              // Indicatore drag handle (più visibile)
              if (!_isDragging)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              if (!_isDragging)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }
}

/// Widget wrapper che gestisce il posizionamento assoluto
class DraggableActionButtonWrapper extends StatelessWidget {
  
  const DraggableActionButtonWrapper({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.positionKey,
    required this.child,
    this.backgroundColor,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final String positionKey;
  final Color? backgroundColor;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Il contenuto principale della schermata
        child,
        
        // Il FAB draggabile sovrapposto
        DraggableActionButton(
          onPressed: onPressed,
          icon: icon,
          label: label,
          positionKey: positionKey,
          backgroundColor: backgroundColor,
        ),
      ],
    );
  }
}

/// Provider per gestire le preferenze di posizione globalmente
class ActionButtonPosition {
  static const String _prefixKey = 'fab_position_';
  
  static Future<bool> isOnLeft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefixKey$key') == 'left';
  }
  
  static Future<void> setPosition(String key, bool isLeft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixKey$key', isLeft ? 'left' : 'right');
  }
  
  static Future<void> resetAllPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefixKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
