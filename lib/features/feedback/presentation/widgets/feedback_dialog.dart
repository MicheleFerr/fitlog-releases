/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/presentation/widgets
/// 🎯 Feature: user_feedback
/// 🔧 Type: dialog
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// FEEDBACK DIALOG - Dialog for collecting user feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/presentation/providers/feedback_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Dialog for submitting feedback
class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({super.key});

  /// Show the dialog
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  FeedbackCategory _selectedCategory = FeedbackCategory.other;
  int? _rating;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.feedback,
                        color: context.colors.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Send Feedback',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Category selection
                Text(
                  'Category',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FeedbackCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(category.name.toUpperCase()),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: context.colors.primary,
                      backgroundColor: context.colors.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      labelStyle: context.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? context.colors.onPrimary
                            : context.colors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                // Rating
                Text(
                  'Rate your experience (optional)',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = _rating == starValue ? null : starValue;
                        });
                      },
                      icon: Icon(
                        _rating != null && starValue <= _rating!
                            ? AppIcons.star
                            : AppIcons.starBorder,
                        color: context.colors.warning,
                        size: 32,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20),

                // Message
                Text(
                  'Your feedback',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    if (value.trim().length < 10) {
                      return 'Please provide more details (min 10 characters)';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: context.colors.onSurface),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submitFeedback,
                      icon: Icon(AppIcons.send),
                      label: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        SnackBarService.showError(context, 'Please sign in to send feedback');
      }
      return;
    }

    // Get app version
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';

    // Get device info
    final platform = Platform.operatingSystem;
    final version = Platform.operatingSystemVersion;
    final deviceInfo = '$platform $version';

    final feedback = UserFeedbackFactory.create(
      userId: user.uid,
      message: _messageController.text.trim(),
      category: _selectedCategory,
      rating: _rating,
      userEmail: user.email,
      userDisplayName: user.displayName,
      deviceInfo: deviceInfo,
      appVersion: appVersion,
    );

    final notifier = ref.read(feedbackNotifierProvider.notifier);
    final success = await notifier.submitFeedback(feedback);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        SnackBarService.showSuccess(
          context,
          'Thank you for your feedback! 🙏',
        );
      } else {
        SnackBarService.showError(
          context,
          'Failed to submit feedback. Please try again.',
        );
      }
    }
  }
}
