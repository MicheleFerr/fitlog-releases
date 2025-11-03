import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExecuteSetStep extends StatefulWidget {

  const ExecuteSetStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  State<ExecuteSetStep> createState() => _ExecuteSetStepState();
}

class _ExecuteSetStepState extends State<ExecuteSetStep> with TickerProviderStateMixin {
  bool _showDemo = false;
  bool _isCompleted = false;
  bool _showQuickEdit = false;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  // Mock set data (realistic weights for bench press)
  final List<Map<String, dynamic>> _mockSets = [
    {
      'weight': 60.0,
      'reps': 12,
      'targetReps': 12,
      'completed': false,
      'isEditing': false,
      'rpe': null,
      'notes': '',
      'restTime': 90,
    },
    {
      'weight': 65.0,
      'reps': 10,
      'targetReps': 10,
      'completed': false,
      'isEditing': false,
      'rpe': null,
      'notes': '',
      'restTime': 90,
    },
    {
      'weight': 70.0,
      'reps': 8,
      'targetReps': 8,
      'completed': false,
      'isEditing': false,
      'rpe': null,
      'notes': '',
      'restTime': 120,
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _startDemo() {
    setState(() {
      _showDemo = true;
    });
    _slideController.forward();
  }

  void _markSetCompleted(int index) {
    setState(() {
      _mockSets[index]['completed'] = true;
    });
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Check if all sets are completed
    final allCompleted = _mockSets.every((set) => set['completed'] == true);
    if (allCompleted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isCompleted = true;
        });
      });
    }
  }

  void _toggleQuickEdit(int index) {
    setState(() {
      _mockSets[index]['isEditing'] = !_mockSets[index]['isEditing'];
      _showQuickEdit = _mockSets[index]['isEditing'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.completeOutline,
            size: 80,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.executeSetStepTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.executeSetStepDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Interactive Demo Section
          if (!_showDemo) ...[
            FilledButton.icon(
              onPressed: _startDemo,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.onboardingTryItOut),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ] else ...[
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Exercise Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'it'
                                ? 'Panca Piana'
                                : 'Bench Press',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PETTO, TRIC',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Mock Sets
                    ...List.generate(_mockSets.length, (index) {
                      final set = _mockSets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Stack(
                          children: [
                            ScaleTransition(
                              scale: set['completed'] ? _bounceAnimation :
                                      const AlwaysStoppedAnimation(1.0),
                              child: _MockSetRow(
                                setNumber: index + 1,
                                set: set,
                                colorScheme: colorScheme,
                                theme: theme,
                                l10n: l10n,
                                onMarkCompleted: () => _markSetCompleted(index),
                                onToggleEdit: () => _toggleQuickEdit(index),
                              ),
                            ),
                            // Show QuickEdit V2 overlay when editing
                            if (set['isEditing'])
                              Positioned.fill(
                                child: _MockQuickEditV2(
                                  set: set,
                                  colorScheme: colorScheme,
                                  theme: theme,
                                  onSave: () => _toggleQuickEdit(index),
                                  onCancel: () => _toggleQuickEdit(index),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    if (!_isCompleted && _mockSets.any((set) => !set['completed'])) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.onboardingTapToComplete,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],

                    if (_isCompleted) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.onboardingCompleted,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MockSetRow extends StatelessWidget {

  const _MockSetRow({
    required this.setNumber,
    required this.set,
    required this.colorScheme,
    required this.theme,
    required this.l10n,
    required this.onMarkCompleted,
    required this.onToggleEdit,
  });
  final int setNumber;
  final Map<String, dynamic> set;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onMarkCompleted;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final isCompleted = set['completed'] == true;
    final isEditing = set['isEditing'] == true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isCompleted
          ? colorScheme.primaryContainer
          : colorScheme.surface,
        border: Border.all(
          color: isCompleted
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                setNumber.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Weight and reps
          Expanded(
            child: Row(
              children: [
                _SetValueChip(
                  icon: Icons.fitness_center,
                  value: '${set['weight'].toStringAsFixed(0)} kg',
                  colorScheme: colorScheme,
                  theme: theme,
                  isCompleted: isCompleted,
                ),
                const SizedBox(width: 8),
                _SetValueChip(
                  icon: Icons.repeat,
                  value: '${set['reps']} / ${set['targetReps']}',
                  colorScheme: colorScheme,
                  theme: theme,
                  isCompleted: isCompleted,
                ),
                const SizedBox(width: 8),
                if (set['rpe'] != null)
                  _SetValueChip(
                    icon: Icons.psychology,
                    value: 'RPE ${set['rpe']}',
                    colorScheme: colorScheme,
                    theme: theme,
                    isCompleted: isCompleted,
                  ),
              ],
            ),
          ),

          // Quick Edit Button
          if (!isCompleted && !isEditing)
            IconButton(
              onPressed: onToggleEdit,
              icon: Icon(
                Icons.edit,
                size: 18,
                color: colorScheme.primary,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(32, 32),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),

          if (isEditing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onToggleEdit,
                  icon: Icon(
                    Icons.check,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onToggleEdit,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),

          const SizedBox(width: 8),

          // Completion button
          GestureDetector(
            onTap: isCompleted ? null : onMarkCompleted,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : AppIcons.checkBoxOutlineBlank,
                color: isCompleted
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockQuickEditV2 extends StatelessWidget {

  const _MockQuickEditV2({
    required this.set,
    required this.colorScheme,
    required this.theme,
    required this.onSave,
    required this.onCancel,
  });
  final Map<String, dynamic> set;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(
                isItalian ? 'Modifica Rapida' : 'Quick Edit',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weight and Reps Controls
          Row(
            children: [
              // Weight
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isItalian ? 'Peso (kg)' : 'Weight (kg)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove, size: 16),
                            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${set['weight'].toStringAsFixed(1)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 16),
                            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Reps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isItalian ? 'Ripetizioni' : 'Reps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove, size: 16),
                            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${set['reps']}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 16),
                            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // RPE and Notes
          Row(
            children: [
              // RPE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RPE (6-10)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          set['rpe']?.toString() ?? '-',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Notes button
              IconButton(
                onPressed: () {},
                icon: const Icon(AppIcons.noteAdd, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isItalian ? 'Salva' : 'Save',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetValueChip extends StatelessWidget {

  const _SetValueChip({
    required this.icon,
    required this.value,
    required this.colorScheme,
    required this.theme,
    required this.isCompleted,
  });
  final IconData icon;
  final String value;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
          ? colorScheme.primary.withValues(alpha: 0.1)
          : colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isCompleted
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCompleted
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}