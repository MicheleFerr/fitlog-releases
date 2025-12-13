/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics_feedback
/// 🔧 Type: widget
/// 🌍 Localization: ✅ (context.l10n)
/// 🎨 Theme: ✅ (context.colors)
/// 📱 Platform: Universal
///
/// ANALYTICS FEEDBACK WIDGET
///
/// Widget feedback per schermata Analytics con sistema eligibility.
/// Mostra feedback form solo se utente è eligible (7+ giorni, 10+ workout).
/// Animazione smooth slide-down per input box commento.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_page_feedback.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_feedback_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Widget feedback per Analytics con eligibility check
class AnalyticsFeedbackWidget extends ConsumerStatefulWidget {
  const AnalyticsFeedbackWidget({super.key});

  @override
  ConsumerState<AnalyticsFeedbackWidget> createState() =>
      _AnalyticsFeedbackWidgetState();
}

class _AnalyticsFeedbackWidgetState
    extends ConsumerState<AnalyticsFeedbackWidget>
    with SingleTickerProviderStateMixin {
  // Animation controller per slide-down
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Stato feedback
  bool? _selectedFeedback; // null = non selezionato, true = 👍, false = 👎
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check eligibility
    final eligibilityAsync = ref.watch(feedbackEligibilityProvider);

    return eligibilityAsync.when(
      data: (isEligible) {
        if (!isEligible) {
          // Non eligible → nasconde widget
          return const SizedBox.shrink();
        }

        // Check se ha già dato feedback recente
        final lastFeedbackAsync = ref.watch(userLastAnalyticsFeedbackProvider);

        return lastFeedbackAsync.when(
          data: (lastFeedback) {
            // Se ha feedback recente (< 30 giorni), mostra "Grazie"
            if (lastFeedback != null && lastFeedback.isRecent()) {
              return _buildThankYouMessage(context, lastFeedback.timestamp);
            }

            // Eligible e nessun feedback recente → mostra form
            return _buildFeedbackForm(context);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Messaggio "Grazie" per feedback recente
  Widget _buildThankYouMessage(BuildContext context, DateTime feedbackDate) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.checkCircle,
            color: context.colors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.analyticsFeedbackThankYou,
                  style: textTheme.titleSmall?.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.analyticsFeedbackThankYouSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Form feedback principale
  Widget _buildFeedbackForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final submissionState = ref.watch(analyticsFeedbackNotifierProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 Titolo + Emoji
          Row(
            children: [
              Text(
                '📊',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.analyticsFeedbackQuestion,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 👍👎 Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👍 Utile
              _buildFeedbackButton(
                context: context,
                label: context.l10n.analyticsFeedbackHelpful,
                icon: AppIcons.thumbUp,
                isHelpful: true,
                isSelected: _selectedFeedback == true,
                onTap: () => _onFeedbackSelected(true),
              ),

              const SizedBox(width: 16),

              // 👎 Non utile
              _buildFeedbackButton(
                context: context,
                label: context.l10n.analyticsFeedbackNotHelpful,
                icon: AppIcons.thumbDown,
                isHelpful: false,
                isSelected: _selectedFeedback == false,
                onTap: () => _onFeedbackSelected(false),
              ),
            ],
          ),

          // 📝 Animated comment input box
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1.0,
            child: Column(
              children: [
                const SizedBox(height: 16),

                // TextField commento
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: context.l10n.analyticsFeedbackCommentPlaceholder,
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: submissionState.isLoading
                        ? null
                        : _onSubmitFeedback,
                    icon: submissionState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: LoadingIndicator(),
                          )
                        : const SemanticIcon(
  icon: AppIcons.send,
  semanticLabel: 'Send',
),
                    label: Text(
                      submissionState.isLoading
                          ? context.l10n.analyticsFeedbackSubmitting
                          : context.l10n.analyticsFeedbackSubmit,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (submissionState.hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.errorOutline,
                    color: context.colors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.analyticsFeedbackError,
                      style: textTheme.bodySmall?.copyWith(
                        color: context.colors.error,
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

  /// Build feedback button (👍/👎)
  Widget _buildFeedbackButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isHelpful,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final buttonColor = isHelpful ? context.colors.success : context.colors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? buttonColor.withValues(alpha: 0.2)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? buttonColor
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? buttonColor : colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: isSelected ? buttonColor : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handler per selezione feedback
  void _onFeedbackSelected(bool isHelpful) {
    setState(() {
      _selectedFeedback = isHelpful;
    });

    // Avvia animazione slide-down
    _animationController.forward();
  }

  /// Handler per submit feedback
  Future<void> _onSubmitFeedback() async {
    if (_selectedFeedback == null) return;

    final notifier = ref.read(analyticsFeedbackNotifierProvider.notifier);

    await notifier.submitFeedback(
      isHelpful: _selectedFeedback!,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      // TODO: Aggiungere lastViewedSection e totalWorkoutsViewed se necessario
    );

    // Se submission è success, mostra snackbar e resetta form
    final state = ref.read(analyticsFeedbackNotifierProvider);
    if (state.hasValue && !state.hasError && mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.analyticsFeedbackSuccess,
      );

      // Reset form
      setState(() {
        _selectedFeedback = null;
        _commentController.clear();
      });
      unawaited(_animationController.reverse());
    }
  }
}
