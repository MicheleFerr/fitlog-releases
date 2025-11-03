/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_action.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ReportUserDialog extends ConsumerStatefulWidget {

  const ReportUserDialog({
    super.key,
    required this.targetProfile,
    required this.onReport,
  });
  final BuddyProfile targetProfile;
  final Function(ReportReason reason, String? description) onReport;

  @override
  ConsumerState<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends ConsumerState<ReportUserDialog> {
  ReportReason? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onReport(
        _selectedReason!,
        _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        _showReportConfirmation();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la segnalazione: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showReportConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Utente segnalato. Grazie per aver reso GymBro più sicuro.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'OK',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            AppIcons.reportProblem,
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.reportUser,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target user info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.targetProfile.photoURL != null
                        ? NetworkImage(widget.targetProfile.photoURL!)
                        : null,
                    child: widget.targetProfile.photoURL == null
                        ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.targetProfile.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Stai segnalando questo utente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reason selection
            Text(
              'Motivo della segnalazione',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            RadioGroup<ReportReason>(
              groupValue: _selectedReason,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedReason = value;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ReportReason.values.map((reason) {
                  return RadioListTile<ReportReason>(
                    title: Text(
                      _getReasonText(l10n, reason),
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                    ),
                    value: reason,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Optional description
            Text(
              'Dettagli aggiuntivi (opzionale)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Descrivi il problema in dettaglio...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),

            const SizedBox(height: 16),

            // Warning text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.warningAmber,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Le segnalazioni false possono comportare la sospensione del tuo account.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Annulla',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedReason == null ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onError),
                  ),
                )
              : const Text('Segnala'),
        ),
      ],
    );
  }

  String _getReasonText(AppLocalizations l10n, ReportReason reason) {
    switch (reason) {
      case ReportReason.inappropriatePhotos:
        return l10n.reportReasonInappropriatePhotos;
      case ReportReason.harassment:
        return l10n.reportReasonHarassment;
      case ReportReason.spam:
        return l10n.reportReasonSpam;
      case ReportReason.fakeProfile:
        return l10n.reportReasonFakeProfile;
      case ReportReason.underage:
        return l10n.reportReasonUnderage;
      case ReportReason.other:
        return l10n.reportReasonOther;
    }
  }

  static void show({
    required BuildContext context,
    required BuddyProfile targetProfile,
    required Function(ReportReason reason, String? description) onReport,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportUserDialog(
        targetProfile: targetProfile,
        onReport: onReport,
      ),
    );
  }
}

/// Block user confirmation dialog
class BlockUserDialog extends ConsumerWidget {

  const BlockUserDialog({
    super.key,
    required this.targetProfile,
    required this.onBlock,
  });
  final BuddyProfile targetProfile;
  final Function(String? reason) onBlock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            AppIcons.block,
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.blockUser,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Target user info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: targetProfile.photoURL != null
                      ? NetworkImage(targetProfile.photoURL!)
                      : null,
                  child: targetProfile.photoURL == null
                      ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetProfile.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Non vedrete più i profili l\'uno dell\'altro',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Sei sicuro di voler bloccare questo utente? Potrai sbloccare in seguito dalle impostazioni.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annulla',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onBlock(null);
            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${targetProfile.displayName} è stato bloccato'),
                backgroundColor: colorScheme.primary,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: const Text('Blocca'),
        ),
      ],
    );
  }

  static void show({
    required BuildContext context,
    required BuddyProfile targetProfile,
    required Function(String? reason) onBlock,
  }) {
    showDialog(
      context: context,
      builder: (context) => BlockUserDialog(
        targetProfile: targetProfile,
        onBlock: onBlock,
      ),
    );
  }
}