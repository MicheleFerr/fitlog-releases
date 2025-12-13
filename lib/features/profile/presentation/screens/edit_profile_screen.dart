/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/screens
/// Feature: Edit Profile
/// Type: Screen
///
/// Screen for editing user profile data including personal information
/// like name, age, height, weight, etc.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

/// Edit profile screen for managing personal data
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String? _selectedGender;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();

    // Load fitness profile data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFitnessProfile();
    });
  }

  Future<void> _loadFitnessProfile() async {
    final notifier = ref.read(userFitnessQuestionnaireProvider.notifier);
    await notifier.loadQuestionnaire();

    final questionnaire = ref.read(userFitnessQuestionnaireProvider);
    if (questionnaire != null && !_hasChanges) {
      setState(() {
        _ageController.text = questionnaire.age.toString();
        _heightController.text = questionnaire.heightCm.toInt().toString();
        _weightController.text = questionnaire.bodyweightKg.toString();
        _selectedGender = _biologicalSexToGenderString(questionnaire.sex);
      });
    }
  }

  String _biologicalSexToGenderString(BiologicalSex sex) {
    switch (sex) {
      case BiologicalSex.male:
        return 'male';
      case BiologicalSex.female:
        return 'female';
    }
  }

  BiologicalSex _genderStringToBiologicalSex(String gender) {
    switch (gender) {
      case 'male':
        return BiologicalSex.male;
      case 'female':
        return BiologicalSex.female;
      default:
        return BiologicalSex.male; // Default fallback
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _loadUserData(UserModel? user) {
    if (user != null && !_hasChanges) {
      _displayNameController.text = user.displayName;
      // Additional fields would be loaded from user profile data
      // These fields can be extended based on UserModel properties
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = FirebaseAuth.instance.currentUser;

      // Update display name via Firebase Auth
      final newDisplayName = _displayNameController.text.trim();
      if (newDisplayName.isNotEmpty && currentUser != null) {
        await currentUser.updateDisplayName(newDisplayName);
        // Also update in Firestore
        await authService.updateUserDocument(currentUser.uid, {
          'displayName': newDisplayName,
        });
      }

      // Save fitness profile data (age, height, weight, gender)
      await _saveFitnessProfile();

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.profileUpdated,
        );
        _hasChanges = false;
        // Invalidate user provider to refresh data
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          '${context.l10n.errorSavingProfile}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFitnessProfile() async {
    // Parse values from controllers
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final gender = _selectedGender;

    // Validate required fields
    if (age == null || height == null || weight == null || gender == null) {
      return; // Skip if incomplete
    }

    final notifier = ref.read(userFitnessQuestionnaireProvider.notifier);
    final existingQuestionnaire = ref.read(userFitnessQuestionnaireProvider);

    // Create or update questionnaire
    final questionnaire = existingQuestionnaire?.copyWith(
      age: age,
      heightCm: height,
      bodyweightKg: weight,
      sex: _genderStringToBiologicalSex(gender),
    ) ?? UserFitnessQuestionnaire(
      age: age,
      heightCm: height,
      bodyweightKg: weight,
      sex: _genderStringToBiologicalSex(gender),
      experienceLevel: ExperienceLevel.novice, // Default for new profiles
    );

    // Update state and save to Hive
    notifier.updateQuestionnaire(questionnaire);
    await notifier.saveQuestionnaire();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        _loadUserData(user);
        return _buildContent(context, user);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(context.l10n.editProfile)),
        body: const Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.editProfile)),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserModel? user) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBackIos, size: AppIconSize.medium),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: LoadingIndicator(size: 20),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                context.l10n.save,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: () {
          if (!_hasChanges) {
            setState(() {
              _hasChanges = true;
            });
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: context.colors.primaryContainer,
                    child: Text(
                      (user != null && user.displayName.isNotEmpty)
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        AppIcons.camera,
                        size: AppIconSize.small,
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            Text(
              context.l10n.personalInformation,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Display Name
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: context.l10n.displayName,
                prefixIcon: const Icon(AppIcons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Age
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: context.l10n.age,
                prefixIcon: const Icon(AppIcons.calendar),
                suffixText: context.l10n.years,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 13 || age > 120) {
                    return context.l10n.pleaseEnterValidAge;
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: context.l10n.gender,
                prefixIcon: const Icon(AppIcons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'male',
                  child: Text(context.l10n.male),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text(context.l10n.female),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text(context.l10n.other),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 32),

            // Body Measurements Section
            Text(
              context.l10n.bodyMeasurementsTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Height
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: context.l10n.bodyMeasurementsMetricHeight,
                      prefixIcon: const Icon(AppIcons.bodyMeasurements),
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final height = int.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return context.l10n.pleaseEnterValidHeight;
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: context.l10n.weight,
                      prefixIcon: const Icon(AppIcons.scale),
                      suffixText: 'kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 30 || weight > 300) {
                          return context.l10n.pleaseEnterValidWeight;
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Email (read-only)
            TextFormField(
              initialValue: user?.email ?? '',
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(AppIcons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.colors.surfaceContainerHighest,
              ),
              enabled: false,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.emailCannotBeChanged,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
