import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/gym_equipment_profiles_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/cn_switch_list_tile.dart';

/// Screen for creating or editing a gym equipment profile
class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key, this.profile});

  /// If null, creates a new profile. Otherwise edits existing.
  final GymEquipmentProfile? profile;

  bool get isEditing => profile != null;

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late double? _selectedBarbellWeight;
  late Set<double> _selectedPlates;
  late bool _isDefault;
  bool _isSaving = false;
  bool _isDeleting = false;

  // Common barbell weights
  static const List<double?> _barbellOptions = [
    20.0, // Olympic
    15.0, // Women's Olympic
    10.0, // Technique/Training
    7.5, // EZ Curl
    null, // No barbell
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _selectedBarbellWeight = widget.profile?.defaultBarbellWeight ?? 20.0;
    _selectedPlates = widget.profile?.availablePlates.toSet() ??
        GymEquipmentProfile.standardPlates.toSet();
    _isDefault = widget.profile?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? context.l10n.editProfile
              : context.l10n.createProfile,
        ),
        actions: [
          if (widget.isEditing && !widget.profile!.isDefault)
            IconButton(
              onPressed: _isDeleting ? null : _confirmDelete,
              icon: _isDeleting
                  ? const LoadingIndicator(size: 20)
                  : SemanticIcon(
                      icon: AppIcons.delete,
                      semanticLabel: context.l10n.delete,
                      color: context.colors.error,
                    ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.profileName,
                hintText: context.l10n.profileNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const SemanticIcon(
                  icon: AppIcons.label,
                  semanticLabel: 'Name',
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return context.l10n.profileName;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Barbell selection section
            Text(
              context.l10n.barbell,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.selectBarbellWeight,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Barbell options
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _barbellOptions.map((weight) {
                final isSelected = _selectedBarbellWeight == weight;
                return ChoiceChip(
                  label: Text(
                    weight != null ? '${weight}kg' : context.l10n.noBarbell,
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedBarbellWeight = weight;
                    });
                  },
                  avatar: isSelected
                      ? SemanticIcon(
                          icon: AppIcons.check,
                          semanticLabel: 'Selected',
                          size: AppIconSize.tiny,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Available plates section
            Text(
              context.l10n.availablePlatesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.selectAvailablePlates,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Plate selection chips
            _buildPlateSelector(theme),

            const SizedBox(height: 24),

            // Default profile switch
            if (!widget.isEditing || !widget.profile!.isDefault)
              CNSwitchListTile(
                title: Text(context.l10n.setAsDefault),
                subtitle: Text(
                  context.l10n.defaultProfileDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isDefault,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isDefault = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: LoadingIndicator(size: 20),
                    )
                  : const SemanticIcon(
                      icon: AppIcons.save,
                      semanticLabel: 'Save',
                    ),
              label: Text(context.l10n.saveProfile),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateSelector(ThemeData theme) {
    // All possible plate weights (extended list)
    const allPlates = [
      50.0,
      25.0,
      20.0,
      15.0,
      10.0,
      5.0,
      2.5,
      2.0,
      1.25,
      1.0,
      0.5,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allPlates.map((plate) {
        final isSelected = _selectedPlates.contains(plate);
        return FilterChip(
          label: Text('${plate}kg'),
          selected: isSelected,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedPlates.remove(plate);
              } else {
                _selectedPlates.add(plate);
              }
            });
          },
          avatar: isSelected
              ? SemanticIcon(
                  icon: AppIcons.check,
                  semanticLabel: 'Selected',
                  size: AppIconSize.tiny,
                  color: theme.colorScheme.onSecondaryContainer,
                )
              : null,
          checkmarkColor: theme.colorScheme.onSecondaryContainer,
        );
      }).toList(),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlates.isEmpty) {
      SnackBarService.showError(
        context,
        context.l10n.selectAtLeastOnePlate,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final notifier = ref.read(gymEquipmentProfilesNotifierProvider.notifier);

      if (widget.isEditing) {
        // Update existing profile
        final updated = widget.profile!.copyWith(
          name: _nameController.text.trim(),
          defaultBarbellWeight: _selectedBarbellWeight,
          availablePlates: _selectedPlates.toList()..sort((a, b) => b.compareTo(a)),
          isDefault: _isDefault,
        );
        await notifier.updateProfile(updated);
      } else {
        // Create new profile
        await notifier.createProfile(
          name: _nameController.text.trim(),
          defaultBarbellWeight: _selectedBarbellWeight,
          availablePlates: _selectedPlates.toList()..sort((a, b) => b.compareTo(a)),
          setAsDefault: _isDefault,
        );
      }

      await HapticFeedback.mediumImpact();
      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        widget.isEditing
            ? context.l10n.profileUpdated
            : context.l10n.profileCreated(_nameController.text.trim()),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteProfile),
        content: Text(
          context.l10n.deleteProfileConfirmation(widget.profile!.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProfile();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProfile() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final notifier = ref.read(gymEquipmentProfilesNotifierProvider.notifier);
      await notifier.deleteProfile(widget.profile!.id);

      await HapticFeedback.mediumImpact();
      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        context.l10n.profileDeleted,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
