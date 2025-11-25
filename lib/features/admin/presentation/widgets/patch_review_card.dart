/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Card widget for displaying exercise patch review
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class PatchReviewCard extends StatefulWidget {
  const PatchReviewCard({
    required this.patch,
    this.onApprove,
    this.onReject,
    this.readOnly = false,
    super.key,
  });

  final ExercisePatch patch;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool readOnly;

  @override
  State<PatchReviewCard> createState() => _PatchReviewCardState();
}

class _PatchReviewCardState extends State<PatchReviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleApproveWithHaptic() {
    HapticFeedback.mediumImpact();
    widget.onApprove?.call();
  }

  void _handleRejectWithHaptic() {
    HapticFeedback.lightImpact();
    widget.onReject?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(context),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status badge + timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context),
                Text(
                  DateFormat('dd/MM/yy HH:mm').format(widget.patch.createdAt),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Exercise info
            Text(
              'Exercise ID: ${widget.patch.exerciseId}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Field change
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Field: ${widget.patch.fieldName}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildValueBox(
                          context,
                          'Old',
                          widget.patch.oldValue?.toString() ?? '-',
                          context.colors.error,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SemanticIcon(
  icon: AppIcons.forward,
  semanticLabel: 'Forward',
  size: AppIconSize.small,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
                        ),
                      ),
                      Expanded(
                        child: _buildValueBox(
                          context,
                          'New',
                          widget.patch.newValue?.toString() ?? '-',
                          context.colors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Reason
            Text(
              'Reason:',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.patch.reason,
              style: context.textTheme.bodyMedium,
            ),

            // Action buttons (only if not read-only and pending)
            if (!widget.readOnly && widget.patch.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleRejectWithHaptic,
                      icon: const SemanticIcon(
  icon: AppIcons.cancel,
  semanticLabel: 'Cancel',
  size: AppIconSize.small,
),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.error,
                        side: BorderSide(color: context.colors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleApproveWithHaptic,
                      icon: const SemanticIcon(
  icon: AppIcons.check,
  semanticLabel: 'Check',
  size: AppIconSize.small,
),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.success,
                        foregroundColor: context.colors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Admin note (if reviewed)
            if (widget.patch.adminNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: context.colors.tertiary,
),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.patch.adminNote!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final (icon, label, color) = _getStatusDetails(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String, Color) _getStatusDetails(BuildContext context) {
    if (widget.patch.isPending) {
      return (AppIcons.pending, 'Pending', context.colors.warning);
    } else if (widget.patch.isApproved) {
      return (AppIcons.checkCircle, 'Approved', context.colors.success);
    } else if (widget.patch.isRejected) {
      return (AppIcons.cancel, 'Rejected', context.colors.error);
    } else if (widget.patch.isExpired) {
      return (AppIcons.schedule, 'Expired', context.colors.onSurface.withValues(alpha: 0.5));
    } else {
      return (AppIcons.helpOutline, 'Unknown', context.colors.onSurface);
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (widget.patch.isPending) {
      return context.colors.warning.withValues(alpha: 0.3);
    } else if (widget.patch.isApproved) {
      return context.colors.success.withValues(alpha: 0.3);
    } else if (widget.patch.isRejected) {
      return context.colors.error.withValues(alpha: 0.3);
    } else {
      return context.colors.onSurface.withValues(alpha: 0.2);
    }
  }

  Widget _buildValueBox(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
