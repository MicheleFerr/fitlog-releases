/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Schermata dettaglio feedback con azioni admin
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_feedback_provider.dart';

class FeedbackDetailScreen extends ConsumerStatefulWidget {
  final ExerciseFeedback feedback;

  const FeedbackDetailScreen({
    super.key,
    required this.feedback,
  });

  @override
  ConsumerState<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends ConsumerState<FeedbackDetailScreen> {
  late TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.feedback.adminNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeEmojis = {
      'BUG': '🐛',
      'SUGGESTION': '💡',
      'TYPO': '📝',
      'OTHER': '❓',
    };

    final l10n = context.l10n;

    Color severityColor;
    String severityLabel;
    if (widget.feedback.severity >= 4) {
      severityColor = Colors.red;
      severityLabel = l10n.feedbackSeverityCritical;
    } else if (widget.feedback.severity == 3) {
      severityColor = Colors.orange;
      severityLabel = l10n.feedbackSeverityHigh;
    } else if (widget.feedback.severity == 2) {
      severityColor = Colors.amber;
      severityLabel = l10n.feedbackSeverityMedium;
    } else {
      severityColor = Colors.green;
      severityLabel = l10n.feedbackSeverityLow;
    }

    Color statusColor;
    switch (widget.feedback.status) {
      case 'OPEN':
        statusColor = Colors.orange;
        break;
      case 'REVIEWING':
        statusColor = Colors.blue;
        break;
      case 'RESOLVED':
        statusColor = Colors.green;
        break;
      case 'DISMISSED':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = context.colors.primary;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              typeEmojis[widget.feedback.feedbackType] ?? '•',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.feedback.exerciseName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Status badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Text(
              widget.feedback.status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type & Severity
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            context,
                            icon: Icons.category,
                            label: widget.feedback.feedbackType,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoChip(
                            context,
                            icon: Icons.priority_high,
                            label: severityLabel,
                            color: severityColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // User Info
                    _buildInfoRow(
                      context,
                      icon: Icons.person,
                      label: l10n.feedbackDetailInfoUser,
                      value: widget.feedback.userEmail,
                    ),
                    const SizedBox(height: 8),

                    // Date
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      label: l10n.feedbackDetailInfoCreated,
                      value: _formatDate(widget.feedback.createdAt),
                    ),
                    const SizedBox(height: 8),

                    // Version
                    _buildInfoRow(
                      context,
                      icon: Icons.code,
                      label: l10n.feedbackDetailInfoVersion,
                      value: widget.feedback.version,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          size: 20,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.feedbackDetailUserMessage,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.feedback.message,
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Admin Notes Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 20,
                          color: context.colors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.feedbackDetailAdminNotes,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.feedbackDetailAdminNotesHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveNotes,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(l10n.feedbackDetailSaveNotes),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions Section
            Text(
              l10n.feedbackDetailQuickActions,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Status Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.feedback.status != 'REVIEWING')
                  _buildActionButton(
                    context,
                    label: l10n.feedbackActionStartReview,
                    icon: Icons.rate_review,
                    color: Colors.blue,
                    onTap: () => _updateStatus('REVIEWING'),
                  ),
                if (widget.feedback.status != 'RESOLVED')
                  _buildActionButton(
                    context,
                    label: l10n.feedbackActionMarkResolved,
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onTap: () => _updateStatus('RESOLVED'),
                  ),
                if (widget.feedback.status != 'DISMISSED')
                  _buildActionButton(
                    context,
                    label: l10n.feedbackActionDismiss,
                    icon: Icons.cancel,
                    color: Colors.grey,
                    onTap: () => _updateStatus('DISMISSED'),
                  ),
                if (widget.feedback.status != 'OPEN')
                  _buildActionButton(
                    context,
                    label: l10n.feedbackActionReopen,
                    icon: Icons.undo,
                    color: Colors.orange,
                    onTap: () => _updateStatus('OPEN'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Severity Actions
            Text(
              l10n.feedbackDetailChangeSeverity,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSeverityButton(context, 1, l10n.feedbackSeverityLow, Colors.green),
                _buildSeverityButton(context, 2, l10n.feedbackSeverityMedium, Colors.amber),
                _buildSeverityButton(context, 3, l10n.feedbackSeverityHigh, Colors.orange),
                _buildSeverityButton(context, 4, l10n.feedbackSeverityCritical, Colors.red),
                _buildSeverityButton(context, 5, l10n.feedbackSeverityUrgent, Colors.red.shade900),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSeverityButton(
    BuildContext context,
    int severity,
    String label,
    Color color,
  ) {
    final isSelected = widget.feedback.severity == severity;
    return OutlinedButton(
      onPressed: _isSaving || isSelected ? null : () => _updateSeverity(severity),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.2) : null,
        side: BorderSide(
          color: isSelected ? color : context.colors.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? color : context.colors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('exercise_feedback')
          .doc(widget.feedback.id)
          .update({
        'adminNotes': _notesController.text.trim(),
      });

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.feedbackDetailNotesSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.feedbackDetailNotesError);
      }
      debugPrint('❌ Error saving admin notes: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('exercise_feedback')
          .doc(widget.feedback.id)
          .update({
        'status': newStatus,
      });

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.feedbackStatusUpdated(newStatus));
        // Pop back to refresh list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.feedbackStatusUpdateError);
      }
      debugPrint('❌ Error updating status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateSeverity(int newSeverity) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('exercise_feedback')
          .doc(widget.feedback.id)
          .update({
        'severity': newSeverity,
      });

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.feedbackSeverityUpdated);
        // Pop back to refresh list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.feedbackSeverityUpdateError);
      }
      debugPrint('❌ Error updating severity: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
