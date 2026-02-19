import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/gym_equipment_profiles_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Dialog for quickly creating a gym equipment profile from current configuration
class QuickCreateProfileDialog extends ConsumerStatefulWidget {
  const QuickCreateProfileDialog({
    super.key,
    required this.currentBarbellWeight,
    required this.currentPlates,
  });

  final double? currentBarbellWeight;
  final List<double> currentPlates;

  /// Show the dialog and return the created profile name (or null if cancelled)
  static Future<String?> show(
    BuildContext context, {
    required double? currentBarbellWeight,
    required List<double> currentPlates,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => QuickCreateProfileDialog(
        currentBarbellWeight: currentBarbellWeight,
        currentPlates: currentPlates,
      ),
    );
  }

  @override
  ConsumerState<QuickCreateProfileDialog> createState() =>
      _QuickCreateProfileDialogState();
}

class _QuickCreateProfileDialogState
    extends ConsumerState<QuickCreateProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _setAsDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.save,
            semanticLabel: 'Save',
            size: AppIconSize.medium,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(context.l10n.saveProfile),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.profileName,
                  hintText: context.l10n.profileNameHint,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return context.l10n.profileName;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Current configuration summary
              Text(
                context.l10n.currentConfiguration,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barbell
                    Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.workout,
                          semanticLabel: 'Barbell',
                          size: AppIconSize.tiny,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${context.l10n.barbell}: ${_formatBarbell()}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Plates
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SemanticIcon(
                            icon: AppIcons.circleOutlined,
                            semanticLabel: 'Plates',
                            size: AppIconSize.tiny,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${context.l10n.availablePlatesTitle}: ${_formatPlates()}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Set as default checkbox
              CheckboxListTile(
                value: _setAsDefault,
                onChanged: (value) {
                  setState(() {
                    _setAsDefault = value ?? false;
                  });
                },
                title: Text(context.l10n.setAsDefault),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _saveProfile,
          icon: _isLoading
              ? const LoadingIndicator()
              : const SemanticIcon(
                  icon: AppIcons.save,
                  semanticLabel: 'Save',
                  size: AppIconSize.tiny,
                ),
          label: Text(context.l10n.saveProfile),
        ),
      ],
    );
  }

  String _formatBarbell() {
    if (widget.currentBarbellWeight == null) {
      return context.l10n.noBarbell;
    }
    return '${widget.currentBarbellWeight}kg';
  }

  String _formatPlates() {
    if (widget.currentPlates.isEmpty) {
      return '-';
    }
    return widget.currentPlates.map((p) => '${p}kg').join(', ');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(gymEquipmentProfilesNotifierProvider.notifier);
      final profile = await notifier.createProfile(
        name: _nameController.text.trim(),
        defaultBarbellWeight: widget.currentBarbellWeight,
        availablePlates: widget.currentPlates,
        setAsDefault: _setAsDefault,
      );

      if (profile != null && mounted) {
        await HapticFeedback.mediumImpact();
        if (!mounted) return;
        SnackBarService.showSuccess(
          context,
          context.l10n.profileCreated(profile.name),
        );
        Navigator.of(context).pop(profile.name);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
