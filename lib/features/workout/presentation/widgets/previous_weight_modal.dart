/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: Modal widget
/// 🌍 Localization: ✅ Full (context.l10n)
/// 🎨 Theme: ✅ Theme-aware (context.colors)
/// 📱 Platform: Universal
///
/// ✅ PREVIOUS_WEIGHT_MODAL: Modal per scegliere come usare i pesi precedenti
/// - Opzione: Usa pesi precedenti (0%)
/// - Opzione: Aumenta del X% (0.5% - 5%)
/// - Picker per selezionare percentuale
/// - Design moderno e intuitivo
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';

/// Modal per scegliere come applicare i pesi precedenti
///
/// Opzioni:
/// 1. Usa pesi precedenti (0%)
/// 2. Aumenta del X% (con picker 0.5% - 5%)
///
/// Returns: double (percentuale selezionata: 0.0 = 0%, 0.005 = 0.5%, etc.)
/// Returns null se utente cancella/chiude modal
class PreviousWeightModal extends StatefulWidget {
  const PreviousWeightModal({super.key});

  @override
  State<PreviousWeightModal> createState() => _PreviousWeightModalState();
}

class _PreviousWeightModalState extends State<PreviousWeightModal> {
  // Percentuali disponibili: 0%, 0.5%, 1%, 1.5%, 2%, 2.5%, 3%, 3.5%, 4%, 4.5%, 5%
  static const List<double> _percentageOptions = [
    0.0,
    0.5,
    1.0,
    1.5,
    2.0,
    2.5,
    3.0,
    3.5,
    4.0,
    4.5,
    5.0,
  ];

  int _selectedIndex = 0; // Default: 0% (usa pesi precedenti)

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Icon(
                AppIcons.history,
                size: AppIconSize.large,
                color: context.iconPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.usePreviousWeights,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.selectWeightIncrease,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Percentage picker
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListWheelScrollView.useDelegate(
              controller: FixedExtentScrollController(initialItem: _selectedIndex),
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _percentageOptions.length,
                builder: (context, index) {
                  final percentage = _percentageOptions[index];
                  final isSelected = index == _selectedIndex;

                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (percentage == 0.0) ...[
                            Icon(
                              AppIcons.check,
                              size: AppIconSize.small,
                              color: isSelected
                                  ? context.iconPrimary
                                  : context.iconSecondary,
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            Icon(
                              AppIcons.trendingUp,
                              size: AppIconSize.small,
                              color: isSelected
                                  ? context.iconSuccess
                                  : context.iconSecondary,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            percentage == 0.0
                                ? context.l10n.sameWeights
                                : '+${percentage.toStringAsFixed(1)}%',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? context.colors.onPrimaryContainer
                                  : context.colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info text based on selection
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedIndex == 0
                  ? context.colors.secondaryContainer.withValues(alpha: 0.3)
                  : context.colors.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedIndex == 0 ? AppIcons.info : AppIcons.tip,
                  size: AppIconSize.small,
                  color: _selectedIndex == 0
                      ? context.iconSecondary
                      : context.iconSuccess,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedIndex == 0
                        ? context.l10n.sameWeightsInfo
                        : context.l10n.increaseWeightsInfo(
                            _percentageOptions[_selectedIndex].toStringAsFixed(1),
                          ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(context.l10n.skip),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    final selectedPercentage = _percentageOptions[_selectedIndex];
                    Navigator.of(context).pop(selectedPercentage);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(context.l10n.apply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the modal
///
/// Returns:
/// - double (0.0 - 5.0) se l'utente seleziona una percentuale
/// - null se l'utente cancella o chiude il modal
Future<double?> showPreviousWeightModal(BuildContext context) async {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PreviousWeightModal(),
  );
}
