import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/plate_calculator_widget.dart';

class EnhancedQuickEditOverlay extends ConsumerStatefulWidget {
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet;
  final List<double>? recentWeights; // Recent weights for this exercise
  final double? oneRepMax; // 1RM for percentage training

  const EnhancedQuickEditOverlay({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
    this.recentWeights,
    this.oneRepMax,
  });

  @override
  ConsumerState<EnhancedQuickEditOverlay> createState() => _EnhancedQuickEditOverlayState();
}

class _EnhancedQuickEditOverlayState extends ConsumerState<EnhancedQuickEditOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late TabController _tabController;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _percentageController;
  
  double _selectedWeight = 0.0;
  int _selectedReps = 0;
  double _selectedPercentage = 80.0;
  int? _selectedRpe;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing values
    _selectedWeight = widget.exerciseSet.weight ?? 20.0;
    _selectedReps = widget.exerciseSet.reps ?? 10;
    _selectedRpe = widget.exerciseSet.rpe;
    
    _weightController = TextEditingController(text: _selectedWeight.toString());
    _repsController = TextEditingController(text: _selectedReps.toString());
    _percentageController = TextEditingController(text: _selectedPercentage.toString());
    
    _tabController = TabController(length: 3, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _percentageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate position to keep overlay on screen
    double left = widget.position.dx - 200; // Center the overlay (400/2)
    double top = widget.position.dy - 250;
    
    // Keep within screen bounds
    left = left.clamp(16.0, screenSize.width - 416.0);
    top = top.clamp(50.0, screenSize.height - 550.0);

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surface,
                shadowColor: Colors.black.withOpacity(0.4),
                child: Container(
                  width: 400,
                  constraints: const BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with tabs
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 24,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Set ${widget.exerciseSet.setNumber}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Copy from previous button
                                if (widget.previousSet != null)
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    onPressed: _copyFromPreviousSet,
                                    style: IconButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _cancel,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Tab bar
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelColor: theme.colorScheme.onPrimary,
                                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                                tabs: const [
                                  Tab(text: 'Weight', icon: Icon(Icons.fitness_center, size: 16)),
                                  Tab(text: 'Plates', icon: Icon(Icons.circle_outlined, size: 16)),
                                  Tab(text: '%', icon: Icon(Icons.percent, size: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tab content
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Weight tab with number pad
                              _buildWeightTab(context, config),
                              // Plates calculator tab
                              _buildPlatesTab(context, config),
                              // Percentage training tab
                              _buildPercentageTab(context),
                            ],
                          ),
                        ),
                      ),
                      
                      // Reps input (always visible)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.repeat, size: 18, color: theme.colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text('Reps:', style: theme.textTheme.labelLarge),
                            const SizedBox(width: 12),
                            ...List.generate(5, (index) {
                              final reps = [6, 8, 10, 12, 15][index];
                              final isSelected = _selectedReps == reps;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _selectedReps = reps);
                                    _repsController.text = reps.toString();
                                    HapticFeedback.selectionClick();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? theme.colorScheme.secondary 
                                          : theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      reps.toString(),
                                      style: TextStyle(
                                        color: isSelected 
                                            ? theme.colorScheme.onSecondary 
                                            : theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  final reps = int.tryParse(value) ?? 0;
                                  setState(() => _selectedReps = reps);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // RPE quick select (if enabled)
                      if (config.rpeTracking ?? true) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.speed, size: 18, color: theme.colorScheme.tertiary),
                              const SizedBox(width: 8),
                              Text('RPE:', style: theme.textTheme.labelLarge),
                              const SizedBox(width: 12),
                              ...List.generate(5, (index) {
                                final rpe = index + 6;
                                final isSelected = _selectedRpe == rpe;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => _selectedRpe = isSelected ? null : rpe);
                                      HapticFeedback.selectionClick();
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? _getRpeColor(rpe) 
                                            : theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        rpe.toString(),
                                        style: TextStyle(
                                          color: isSelected 
                                              ? Colors.white 
                                              : theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Action buttons
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancel,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: _save,
                                icon: const Icon(Icons.check),
                                label: const Text('Save'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildWeightTab(BuildContext context, AppConfig config) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Recent weights chips
        if (widget.recentWeights != null && widget.recentWeights!.isNotEmpty) ...[
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.recentWeights!.length,
              itemBuilder: (context, index) {
                final weight = widget.recentWeights![index];
                final isSelected = (_selectedWeight - weight).abs() < 0.1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedWeight = weight);
                      _weightController.text = weight.toString();
                      HapticFeedback.selectionClick();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${weight}kg',
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Weight display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _selectedWeight.toStringAsFixed(_selectedWeight % 1 == 0 ? 0 : 1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                config.measurementUnit,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        
        // Number pad
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...[7, 8, 9, 4, 5, 6, 1, 2, 3].map((number) => _buildNumberButton(number.toString())),
              _buildNumberButton('.'),
              _buildNumberButton('0'),
              _buildNumberButton('⌫', isDelete: true),
            ],
          ),
        ),
        
        // Quick increment buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _adjustWeight(-2.5),
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _adjustWeight(-2.5),
              child: const Text('-2.5'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _adjustWeight(2.5),
              child: const Text('+2.5'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _adjustWeight(5),
              child: const Text('+5'),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _adjustWeight(2.5),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatesTab(BuildContext context, AppConfig config) {
    return SingleChildScrollView(
      child: PlateCalculatorWidget(
        targetWeight: _selectedWeight,
        onWeightChanged: (weight) {
          setState(() {
            _selectedWeight = weight;
            _weightController.text = weight.toString();
          });
        },
        unit: config.measurementUnit,
      ),
    );
  }

  Widget _buildPercentageTab(BuildContext context) {
    final theme = Theme.of(context);
    final oneRM = widget.oneRepMax ?? 100.0;
    final calculatedWeight = (oneRM * _selectedPercentage / 100).roundToDouble();
    
    return Column(
      children: [
        // 1RM display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                '1RM: ${oneRM}kg',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _calculate1RM,
                child: const Text('Calculate'),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Percentage slider
        Column(
          children: [
            Text(
              '${_selectedPercentage.toInt()}%',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '= ${calculatedWeight}kg',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _selectedPercentage,
              min: 30,
              max: 100,
              divisions: 14,
              label: '${_selectedPercentage.toInt()}%',
              onChanged: (value) {
                setState(() {
                  _selectedPercentage = value;
                  _selectedWeight = (oneRM * value / 100).roundToDouble();
                  _weightController.text = _selectedWeight.toString();
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Training zones
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPercentageChip('Warmup', 40, Colors.green),
            _buildPercentageChip('Speed', 50, Colors.blue),
            _buildPercentageChip('Power', 60, Colors.orange),
            _buildPercentageChip('Strength', 75, Colors.red),
            _buildPercentageChip('Heavy', 85, Colors.purple),
            _buildPercentageChip('Max', 95, Colors.deepPurple),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String text, {bool isDelete = false}) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (isDelete) {
          if (_weightController.text.isNotEmpty) {
            _weightController.text = _weightController.text.substring(0, _weightController.text.length - 1);
          }
        } else {
          _weightController.text += text;
        }
        _selectedWeight = double.tryParse(_weightController.text) ?? 0;
        setState(() {});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDelete 
              ? theme.colorScheme.errorContainer.withOpacity(0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace, color: theme.colorScheme.error)
              : Text(
                  text,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPercentageChip(String label, double percentage, Color color) {
    final isSelected = (_selectedPercentage - percentage).abs() < 5;
    
    return InkWell(
      onTap: () {
        setState(() => _selectedPercentage = percentage);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ${percentage.toInt()}%',
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getRpeColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  void _adjustWeight(double increment) {
    setState(() {
      _selectedWeight = (_selectedWeight + increment).clamp(0, 500);
      _weightController.text = _selectedWeight.toString();
    });
    HapticFeedback.selectionClick();
  }

  void _copyFromPreviousSet() {
    if (widget.previousSet == null) return;
    
    setState(() {
      _selectedWeight = widget.previousSet!.weight ?? _selectedWeight;
      _selectedReps = widget.previousSet!.reps ?? _selectedReps;
      _selectedRpe = widget.previousSet!.rpe;
      
      _weightController.text = _selectedWeight.toString();
      _repsController.text = _selectedReps.toString();
    });
    
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied from Set ${widget.previousSet!.setNumber}'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _calculate1RM() {
    // Show 1RM calculator modal
    // TODO: Implement 1RM calculator
  }

  void _save() {
    final updatedSet = widget.exerciseSet.copyWith(
      weight: _selectedWeight > 0 ? _selectedWeight : null,
      reps: _selectedReps > 0 ? _selectedReps : null,
      rpe: _selectedRpe,
    );

    HapticFeedback.mediumImpact();
    widget.onSave(updatedSet);
    _animateOut();
  }

  void _cancel() {
    widget.onCancel();
    _animateOut();
  }

  void _animateOut() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

// Extension for easy overlay showing
extension EnhancedQuickEditOverlayExtension on BuildContext {
  Future<void> showEnhancedQuickEditOverlay({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    required Offset position,
    ExerciseSet? previousSet,
    List<double>? recentWeights,
    double? oneRepMax,
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.black26,
      builder: (context) => Stack(
        children: [
          // Transparent barrier that closes overlay when tapped
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          EnhancedQuickEditOverlay(
            exerciseSet: exerciseSet,
            onSave: onSave,
            onCancel: () => Navigator.of(context).pop(),
            position: position,
            previousSet: previousSet,
            recentWeights: recentWeights,
            oneRepMax: oneRepMax,
          ),
        ],
      ),
    );
  }
}