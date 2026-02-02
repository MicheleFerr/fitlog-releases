/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget (dialog)
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dialog per selezionare il livello di dettaglio per l'esportazione PDF.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/pdf_preferences_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Mostra il dialog per selezionare le opzioni di esportazione PDF
/// Ritorna il [PdfDetailLevel] selezionato, o null se l'utente annulla
Future<PdfDetailLevel?> showPdfExportOptionsDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  return showDialog<PdfDetailLevel>(
    context: context,
    builder: (context) => const PdfExportOptionsDialog(),
  );
}

/// Dialog per selezionare il formato di esportazione PDF
class PdfExportOptionsDialog extends ConsumerStatefulWidget {
  const PdfExportOptionsDialog({super.key});

  @override
  ConsumerState<PdfExportOptionsDialog> createState() => _PdfExportOptionsDialogState();
}

class _PdfExportOptionsDialogState extends ConsumerState<PdfExportOptionsDialog> {
  late PdfDetailLevel _selectedLevel;
  bool _rememberChoice = false;

  @override
  void initState() {
    super.initState();
    // Imposta il valore di default (compatto) o quello salvato
    final savedPreference = ref.read(pdfPreferencesProvider);
    _selectedLevel = savedPreference ?? PdfDetailLevel.compact;
    _rememberChoice = savedPreference != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.pdfExportOptions),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RadioGroup per gestire la selezione
            RadioGroup<PdfDetailLevel>(
              groupValue: _selectedLevel,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLevel = newValue;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Opzione 1: Formato Compatto
                  _buildOptionTile(
                    context,
                    value: PdfDetailLevel.compact,
                    title: l10n.pdfDetailLevelCompact,
                    description: l10n.pdfDetailLevelCompactDesc,
                  ),
                  const SizedBox(height: 8),

                  // Opzione 2: Dettagliato con Peso
                  _buildOptionTile(
                    context,
                    value: PdfDetailLevel.detailedWithWeight,
                    title: l10n.pdfDetailLevelDetailed,
                    description: l10n.pdfDetailLevelDetailedDesc,
                  ),
                  const SizedBox(height: 8),

                  // Opzione 3: Dettagliato senza Peso
                  _buildOptionTile(
                    context,
                    value: PdfDetailLevel.detailedWithoutWeight,
                    title: l10n.pdfDetailLevelNoWeight,
                    description: l10n.pdfDetailLevelNoWeightDesc,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox: Ricorda la mia scelta
            CheckboxListTile(
              value: _rememberChoice,
              onChanged: (value) {
                setState(() {
                  _rememberChoice = value ?? false;
                });
              },
              title: Text(
                l10n.rememberMyChoice,
                style: theme.textTheme.bodyMedium,
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        // Pulsante Annulla
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),

        // Pulsante Conferma
        FilledButton(
          onPressed: () async {
            // Salva la preferenza se richiesto
            if (_rememberChoice) {
              await ref.read(pdfPreferencesProvider.notifier).savePreference(_selectedLevel);
            } else {
              // Rimuovi eventuali preferenze salvate in precedenza
              await ref.read(pdfPreferencesProvider.notifier).clearPreference();
            }

            // Ritorna il livello selezionato
            if (context.mounted) {
              Navigator.of(context).pop(_selectedLevel);
            }
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }

  /// Costruisce una tile per un'opzione radio
  Widget _buildOptionTile(
    BuildContext context, {
    required PdfDetailLevel value,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedLevel == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surface.withValues(alpha: 0),
        ),
        child: Row(
          children: [
            // Radio button
            Radio<PdfDetailLevel>(
              value: value,
            ),
            const SizedBox(width: 8),

            // Titolo e descrizione
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
