/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: strength_standards
/// 🔧 Type: widget
/// 🌍 Localization: ✅ Full support (EN/IT)
/// 🎨 Theme: ✅ Adapts to theme
/// 📱 Platform: Universal
///
/// In-app feedback widget for rating questionnaire steps (1-5 stars)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Widget for collecting user feedback on questionnaire steps
class StepFeedbackWidget extends StatefulWidget {
  const StepFeedbackWidget({
    required this.stepNumber,
    required this.onRatingChanged,
    this.initialRating,
    super.key,
  });

  final int stepNumber;
  final int? initialRating;
  final void Function(int rating) onRatingChanged;

  @override
  State<StepFeedbackWidget> createState() => _StepFeedbackWidgetState();
}

class _StepFeedbackWidgetState extends State<StepFeedbackWidget> {
  int? _currentRating;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(top: 24),
      child: Card(
        elevation: _isExpanded ? 4 : 2,
        color: _isExpanded
            ? context.colors.primaryContainer
            : context.colors.surfaceContainerHighest,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - always visible
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _currentRating != null
                          ? Icons.check_circle
                          : Icons.feedback_outlined,
                      color: _currentRating != null
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentRating != null
                            ? context.l10n.feedbackThankYou
                            : context.l10n.feedbackPrompt,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: _isExpanded
                              ? context.colors.onPrimaryContainer
                              : context.colors.onSurface,
                          fontWeight: _currentRating != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_currentRating != null)
                      _buildStarRating(_currentRating!, size: 16, compact: true)
                    else
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: context.colors.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),

            // Expanded rating content
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.feedbackQuestion,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Star rating buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        final isSelected = _currentRating == rating;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentRating = rating;
                                _isExpanded = false;
                              });
                              widget.onRatingChanged(rating);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colors.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                color: isSelected
                                    ? context.colors.onPrimary
                                    : context.colors.onPrimaryContainer,
                                size: 32,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Rating labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.feedbackPoor,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimaryContainer
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          context.l10n.feedbackExcellent,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimaryContainer
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating, {double size = 16, bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        compact ? 1 : 5,
        (index) {
          if (compact) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: context.colors.primary,
                  size: size,
                ),
                const SizedBox(width: 4),
                Text(
                  '$rating/5',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: context.colors.primary,
            size: size,
          );
        },
      ),
    );
  }
}
