/// PDF Export Options BottomSheet
///
/// BottomSheet modale per selezionare le opzioni di esportazione PDF.
/// Sostituisce la dialog precedente con un design più moderno.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/pdf_preferences_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Mostra il BottomSheet per selezionare le opzioni di esportazione PDF
/// Ritorna il [PdfDetailLevel] selezionato, o null se l'utente annulla
Future<PdfDetailLevel?> showPdfExportBottomSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  return showModalBottomSheet<PdfDetailLevel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
    builder: (context) => const PdfExportBottomSheet(),
  );
}

/// BottomSheet per selezionare il formato di esportazione PDF
class PdfExportBottomSheet extends ConsumerStatefulWidget {
  const PdfExportBottomSheet({super.key});

  @override
  ConsumerState<PdfExportBottomSheet> createState() =>
      _PdfExportBottomSheetState();
}

class _PdfExportBottomSheetState extends ConsumerState<PdfExportBottomSheet> {
  late PdfDetailLevel _selectedLevel;
  bool _rememberChoice = false;

  @override
  void initState() {
    super.initState();
    final savedPreference = ref.read(pdfPreferencesProvider);
    _selectedLevel = savedPreference ?? PdfDetailLevel.compact;
    _rememberChoice = savedPreference != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            _buildHandleBar(),

            // Header
            _buildHeader(),

            const SizedBox(height: 16),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildOptionCard(
                    value: PdfDetailLevel.compact,
                    icon: AppIcons.viewCompact,
                    title: context.l10n.pdfDetailLevelCompact,
                    description: context.l10n.pdfDetailLevelCompactDesc,
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    value: PdfDetailLevel.detailedWithWeight,
                    icon: AppIcons.fitnessCenter,
                    title: context.l10n.pdfDetailLevelDetailed,
                    description: context.l10n.pdfDetailLevelDetailedDesc,
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    value: PdfDetailLevel.detailedWithoutWeight,
                    icon: AppIcons.formatListNumbered,
                    title: context.l10n.pdfDetailLevelNoWeight,
                    description: context.l10n.pdfDetailLevelNoWeightDesc,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Remember choice switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildRememberSwitch(),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActionButtons(),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.outline.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppIcons.pictureAsPdf,
              color: context.colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.pdfExportOptions,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                Text(
                  context.l10n.selectPdfFormat,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required PdfDetailLevel value,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedLevel == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedLevel = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary.withValues(alpha: 0.2)
                    : context.colors.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.outline,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outline,
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surface.withValues(alpha: 0),
              ),
              child: isSelected
                  ? Icon(
                      AppIcons.check,
                      size: 16,
                      color: context.colors.onPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(AppIcons.save, color: context.colors.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.rememberMyChoice,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          Switch(
            value: _rememberChoice,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _rememberChoice = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(null),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.l10n.cancel),
          ),
        ),
        const SizedBox(width: 12),

        // Confirm button
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _onConfirm,
            icon: Icon(AppIcons.pictureAsPdf, size: 20),
            label: Text(context.l10n.exportPdf),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onConfirm() async {
    HapticFeedback.mediumImpact();

    // Save preference if requested
    if (_rememberChoice) {
      await ref
          .read(pdfPreferencesProvider.notifier)
          .savePreference(_selectedLevel);
    } else {
      await ref.read(pdfPreferencesProvider.notifier).clearPreference();
    }

    // Return selected level
    if (mounted) {
      Navigator.of(context).pop(_selectedLevel);
    }
  }
}
