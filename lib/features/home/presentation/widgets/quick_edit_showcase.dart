import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_edit_set_overlay.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/enhanced_quick_edit_overlay.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/simple_enhanced_quick_edit.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/hybrid_quick_edit_overlay.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_edit_overlay_v2.dart';

class QuickEditShowcase extends ConsumerStatefulWidget {
  const QuickEditShowcase({super.key});

  @override
  ConsumerState<QuickEditShowcase> createState() => _QuickEditShowcaseState();
}

class _QuickEditShowcaseState extends ConsumerState<QuickEditShowcase> {
  // Demo data for testing
  late ExerciseSet _demoSet;
  late ExerciseSet _previousSet;
  final List<double> _recentWeights = [60.0, 65.0, 70.0, 75.0];
  final double _oneRepMax = 100.0;
  
  String _lastEditedVersion = '';
  ExerciseSet? _lastSavedSet;

  @override
  void initState() {
    super.initState();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    _demoSet = ExerciseSet(
      id: 'demo_set_1',
      setNumber: 2,
      reps: 10,
      weight: 65.0,
      isCompleted: false,
    );
    
    _previousSet = ExerciseSet(
      id: 'demo_set_0',
      setNumber: 1,
      reps: 12,
      weight: 60.0,
      isCompleted: true,
    );
  }

  void _showQuickEditVersion(String version) {
    // Get the render box for position
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );

    setState(() {
      _lastEditedVersion = version;
    });

    switch (version) {
      case 'basic':
        context.showQuickEditOverlay(
          exerciseSet: _demoSet,
          onSave: (updatedSet) => _handleSave(updatedSet, version),
          position: position,
          previousSet: _previousSet,
        );
        break;
        
      case 'enhanced':
        context.showEnhancedQuickEditOverlay(
          exerciseSet: _demoSet,
          onSave: (updatedSet) => _handleSave(updatedSet, version),
          position: position,
          previousSet: _previousSet,
          recentWeights: _recentWeights,
          oneRepMax: _oneRepMax,
        );
        break;
        
      case 'simple':
        context.showSimpleEnhancedQuickEdit(
          exerciseSet: _demoSet,
          onSave: (updatedSet) => _handleSave(updatedSet, version),
          position: position,
          previousSet: _previousSet,
        );
        break;
        
      case 'hybrid':
        context.showHybridQuickEditOverlay(
          exerciseSet: _demoSet,
          onSave: (updatedSet) => _handleSave(updatedSet, version),
          position: position,
          previousSet: _previousSet,
          recentWeights: _recentWeights,
        );
        break;
        
      case 'v2':
        context.showQuickEditOverlayV2(
          exerciseSet: _demoSet,
          onSave: (updatedSet) => _handleSave(updatedSet, version),
          position: position,
          previousSet: _previousSet,
        );
        break;
    }
  }

  void _handleSave(ExerciseSet updatedSet, String version) {
    setState(() {
      _lastSavedSet = updatedSet;
      _demoSet = updatedSet; // Update demo set with new values
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved with $version: ${updatedSet.weight}kg × ${updatedSet.reps} reps'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.science,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧪 QuickEdit Test Lab',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tap to test different versions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Reset button
              IconButton(
                onPressed: () {
                  setState(() {
                    _initializeDemoData();
                    _lastSavedSet = null;
                    _lastEditedVersion = '';
                  });
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset demo data',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Current demo set display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Demo Set: ',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${_demoSet.weight}kg × ${_demoSet.reps} reps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (_demoSet.rpe != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'RPE ${_demoSet.rpe}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Version buttons grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildVersionButton(
                'basic',
                'Basic Wheel',
                Icons.radio_button_checked,
                'Original wheel picker',
                theme.colorScheme.primary,
              ),
              _buildVersionButton(
                'enhanced',
                'Enhanced Tabs',
                Icons.tab,
                'With plates & %',
                theme.colorScheme.secondary,
              ),
              _buildVersionButton(
                'simple',
                'Simple Input',
                Icons.keyboard,
                'Text input only',
                theme.colorScheme.tertiary,
              ),
              _buildVersionButton(
                'hybrid',
                'Hybrid',
                Icons.merge_type,
                'Wheel + Input',
                Colors.orange,
              ),
              _buildVersionButton(
                'v2',
                'V2 Superset ⭐',
                Icons.layers,
                'DEFAULT - In use',
                Colors.purple,
              ),
            ],
          ),
          
          // Last saved info
          if (_lastSavedSet != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last saved with $_lastEditedVersion: ${_lastSavedSet!.weight}kg × ${_lastSavedSet!.reps} reps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersionButton(
    String version,
    String label,
    IconData icon,
    String description,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isLastEdited = _lastEditedVersion == version;
    
    return InkWell(
      onTap: () => _showQuickEditVersion(version),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLastEdited 
              ? color.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLastEdited 
                ? color.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isLastEdited ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              description,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}