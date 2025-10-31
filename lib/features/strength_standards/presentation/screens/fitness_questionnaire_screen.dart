/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/screens
/// 🎯 Feature: strength_standards
/// 🔧 Type: screen
/// 🌍 Localization: ✅ Full support (EN/IT)
/// 🎨 Theme: ✅ Adapts to theme
/// 📱 Platform: Universal
///
/// Evidence-based fitness questionnaire with 6 steps:
/// - Step 0: Medical Clearance (PAR-Q+ + ACSM)
/// - Step 1: Demographics (bodyweight, age, sex)
/// - Step 2: Experience Level + months training
/// - Step 3: Max Lifts (optional, with 1RM calculator)
/// - Step 4: Injury History (detailed)
/// - Step 5: Goals & Preferences
/// - Step 6: Review & Submit
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/medical_clearance_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/widgets/step_feedback_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Fitness questionnaire screen with step-by-step flow
class FitnessQuestionnaireScreen extends ConsumerStatefulWidget {
  const FitnessQuestionnaireScreen({super.key});

  @override
  ConsumerState<FitnessQuestionnaireScreen> createState() =>
      _FitnessQuestionnaireScreenState();
}

class _FitnessQuestionnaireScreenState
    extends ConsumerState<FitnessQuestionnaireScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Track questionnaire completion to avoid dispose() errors
  bool _isCompleted = false;

  // Form keys for each step
  final _medicalClearanceKey = GlobalKey<FormState>();
  final _demographicsKey = GlobalKey<FormState>();
  final _experienceKey = GlobalKey<FormState>();
  final _maxLiftsKey = GlobalKey<FormState>();
  final _injuryKey = GlobalKey<FormState>();
  final _goalsKey = GlobalKey<FormState>();

  // Step 0: Medical Clearance
  bool _hasHeartCondition = false;
  bool _hasChestPain = false;
  bool _hasChestPainAtRest = false;
  bool _hasDizzinessOrFainting = false;
  bool _hasBoneJointProblem = false;
  bool _takesHeartMedication = false;
  bool _hasOtherMedicalReason = false;
  bool _isHighRiskAge = false;
  bool _hasFamilyHistory = false;
  bool _currentSmoker = false;
  bool _isObese = false;
  bool _hasDiabetes = false;
  bool _hasHighBloodPressure = false;

  // Step 1: Demographics
  double? _bodyweightKg;
  int? _age;
  BiologicalSex _sex = BiologicalSex.male;

  // Step 2: Experience
  ExperienceLevel _experienceLevel = ExperienceLevel.novice;
  int? _monthsOfTraining;

  // Step 3: Max Lifts (optional)
  double? _benchPressMax;
  double? _squatMax;
  double? _deadliftMax;
  double? _overheadPressMax;

  // Step 4: Injury History
  bool _hasInjuryHistory = false;
  String? _injuryType;
  InjuryRegion? _injuryRegion;
  int? _monthsSinceInjury;
  bool _fullyRecovered = false;
  bool _inRehabilitation = false;
  int _currentPainLevel = 0;

  // Step 5: Goals & Preferences
  TrainingGoal _trainingGoal = TrainingGoal.hypertrophy;
  SuggestionStyle _suggestionStyle = SuggestionStyle.balanced;
  SelfReportCalibration _selfReportCalibration = SelfReportCalibration.realistic;

  @override
  void initState() {
    super.initState();
    // Start analytics tracking session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentQuestionnaireAnalyticsProvider.notifier).startSession();
    });
  }

  @override
  void dispose() {
    // Track abandonment if not completed
    // Note: We use a local flag instead of reading from ref during dispose
    // because ref.read() is not allowed after the widget is disposed
    if (!_isCompleted && mounted) {
      // Use addPostFrameCallback to ensure this runs after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only track if we're still in a valid state
        try {
          ref.read(currentQuestionnaireAnalyticsProvider.notifier)
            .trackAbandon(_currentStep);
        } catch (e) {
          // Silently catch any errors (widget might already be disposed)
        }
      });
    }
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      // Validate current step
      if (!_validateCurrentStep()) return;

      // Track step completion
      ref.read(currentQuestionnaireAnalyticsProvider.notifier)
        .trackStepComplete(_currentStep);

      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _medicalClearanceKey.currentState?.validate() ?? false;
      case 1:
        return _demographicsKey.currentState?.validate() ?? false;
      case 2:
        return _experienceKey.currentState?.validate() ?? false;
      case 3:
        return true; // Max lifts optional
      case 4:
        return _injuryKey.currentState?.validate() ?? false;
      case 5:
        return _goalsKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  Future<void> _completeQuestionnaire() async {
    if (!_validateCurrentStep()) return;

    // Create medical clearance
    final medicalClearance = MedicalClearanceQuestionnaire(
      hasHeartCondition: _hasHeartCondition,
      hasChestPain: _hasChestPain,
      hasChestPainAtRest: _hasChestPainAtRest,
      hasDizzinessOrFainting: _hasDizzinessOrFainting,
      hasBoneJointProblem: _hasBoneJointProblem,
      takesHeartMedication: _takesHeartMedication,
      hasOtherMedicalReason: _hasOtherMedicalReason,
      isHighRiskAge: _isHighRiskAge,
      hasFamilyHistory: _hasFamilyHistory,
      currentSmoker: _currentSmoker,
      isObese: _isObese,
      hasDiabetes: _hasDiabetes,
      hasHighBloodPressure: _hasHighBloodPressure,
      completedAt: DateTime.now(),
      userAcknowledgedRisks: true,
    );

    // Create injury details if applicable
    InjuryDetails? injuryDetails;
    if (_hasInjuryHistory && _injuryType != null && _injuryRegion != null && _monthsSinceInjury != null) {
      injuryDetails = InjuryDetails(
        injuryType: _injuryType!,
        region: _injuryRegion!,
        monthsSinceInjury: _monthsSinceInjury!,
        fullyRecovered: _fullyRecovered,
        inRehabilitation: _inRehabilitation,
      );
    }

    // Create fitness questionnaire
    final questionnaire = UserFitnessQuestionnaire(
      bodyweightKg: _bodyweightKg!,
      age: _age!,
      sex: _sex,
      experienceLevel: _experienceLevel,
      monthsOfTraining: _monthsOfTraining,
      benchPressMax: _benchPressMax,
      squatMax: _squatMax,
      deadliftMax: _deadliftMax,
      overheadPressMax: _overheadPressMax,
      trainingGoal: _trainingGoal,
      hasInjuryHistory: _hasInjuryHistory,
      injuryDetails: injuryDetails,
      currentPainLevel: _currentPainLevel,
      suggestionStyle: _suggestionStyle,
      completedAt: DateTime.now(),
      selfReportCalibration: _selfReportCalibration,
    );

    // Save to providers
    ref.read(medicalClearanceQuestionnaireProvider.notifier).updateClearance(medicalClearance);
    await ref.read(medicalClearanceQuestionnaireProvider.notifier).saveClearance();

    ref.read(userFitnessQuestionnaireProvider.notifier).updateQuestionnaire(questionnaire);
    await ref.read(userFitnessQuestionnaireProvider.notifier).saveQuestionnaire();

    // Track questionnaire completion
    await ref.read(currentQuestionnaireAnalyticsProvider.notifier)
      .trackCompletion();

    // Mark as completed to prevent tracking abandonment in dispose()
    _isCompleted = true;

    // Show success and close
    if (mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.fitnessQuestionnaireComplete,
      );
      Navigator.of(context).pop(true); // Return true to indicate completion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.fitnessQuestionnaireTitle),
        backgroundColor: context.colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / (_totalSteps + 1),
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(context.colors.primary),
          ),

          // Step indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${context.l10n.step} ${_currentStep + 1} ${context.l10n.ofPreposition} ${_totalSteps + 1}',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),

          // Steps
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMedicalClearanceStep(),
                _buildDemographicsStep(),
                _buildExperienceStep(),
                _buildMaxLiftsStep(),
                _buildInjuryStep(),
                _buildGoalsStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: Text(context.l10n.fitnessQuestionnaireBackButton),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _currentStep == _totalSteps
                  ? _completeQuestionnaire
                  : _nextStep,
              child: Text(
                _currentStep == _totalSteps
                    ? context.l10n.fitnessQuestionnaireComplete
                    : context.l10n.fitnessQuestionnaireNextButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalClearanceStep() {
    final clearance = MedicalClearanceQuestionnaire(
      hasHeartCondition: _hasHeartCondition,
      hasChestPain: _hasChestPain,
      hasChestPainAtRest: _hasChestPainAtRest,
      hasDizzinessOrFainting: _hasDizzinessOrFainting,
      hasBoneJointProblem: _hasBoneJointProblem,
      takesHeartMedication: _takesHeartMedication,
      hasOtherMedicalReason: _hasOtherMedicalReason,
      isHighRiskAge: _isHighRiskAge,
      hasFamilyHistory: _hasFamilyHistory,
      currentSmoker: _currentSmoker,
      isObese: _isObese,
      hasDiabetes: _hasDiabetes,
      hasHighBloodPressure: _hasHighBloodPressure,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _medicalClearanceKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.fitnessMedicalClearanceTitle,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.fitnessMedicalClearanceDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // PAR-Q+ Core Questions
            _buildCheckbox(
              context.l10n.fitnessParqHeartCondition,
              _hasHeartCondition,
              (val) => setState(() => _hasHeartCondition = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessParqChestPainActive,
              _hasChestPain,
              (val) => setState(() => _hasChestPain = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessParqChestPainRest,
              _hasChestPainAtRest,
              (val) => setState(() => _hasChestPainAtRest = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessParqDizziness,
              _hasDizzinessOrFainting,
              (val) => setState(() => _hasDizzinessOrFainting = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessParqBoneJoint,
              _hasBoneJointProblem,
              (val) => setState(() => _hasBoneJointProblem = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessParqMedication,
              _takesHeartMedication,
              (val) => setState(() => _takesHeartMedication = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessParqOtherReason,
              _hasOtherMedicalReason,
              (val) => setState(() => _hasOtherMedicalReason = val ?? false),
            ),

            const Divider(height: 32),

            // ACSM Risk Factors
            Text(
              context.l10n.fitnessAcsmTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            _buildCheckbox(
              context.l10n.fitnessAcsmAge,
              _isHighRiskAge,
              (val) => setState(() => _isHighRiskAge = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessAcsmFamilyHistory,
              _hasFamilyHistory,
              (val) => setState(() => _hasFamilyHistory = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessAcsmSmoker,
              _currentSmoker,
              (val) => setState(() => _currentSmoker = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessAcsmObese,
              _isObese,
              (val) => setState(() => _isObese = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessAcsmDiabetes,
              _hasDiabetes,
              (val) => setState(() => _hasDiabetes = val ?? false),
            ),
            _buildCheckbox(
              context.l10n.fitnessAcsmHighBP,
              _hasHighBloodPressure,
              (val) => setState(() => _hasHighBloodPressure = val ?? false),
            ),

            const SizedBox(height: 24),

            // Clearance status card
            if (clearance.needsMedicalClearance)
              Card(
                color: context.colors.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: context.colors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          clearance.getClearanceMessage(Localizations.localeOf(context).languageCode),
                          style: TextStyle(color: context.colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (clearance.cardiovascularRiskFactors == 1)
              Card(
                color: context.colors.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: context.colors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          clearance.getClearanceMessage(Localizations.localeOf(context).languageCode),
                          style: TextStyle(color: context.colors.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: context.colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: context.colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          clearance.getClearanceMessage(Localizations.localeOf(context).languageCode),
                          style: TextStyle(color: context.colors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Feedback widget for step 0
            StepFeedbackWidget(
              stepNumber: 0,
              initialRating: ref.watch(currentQuestionnaireAnalyticsProvider)?.stepFeedback[0],
              onRatingChanged: (rating) {
                ref.read(currentQuestionnaireAnalyticsProvider.notifier)
                  .trackStepFeedback(0, rating);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildDemographicsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _demographicsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.fitnessQuestionnaireDemographicsTitle,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireBodyweightLabel,
                suffixText: context.l10n.fitnessQuestionnaireBodyweightUnit,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _bodyweightKg?.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) return context.l10n.fitnessValidationRequired;
                final weight = double.tryParse(value);
                if (weight == null || weight < 40 || weight > 200) {
                  return context.l10n.fitnessValidationWeight;
                }
                return null;
              },
              onChanged: (value) => _bodyweightKg = double.tryParse(value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireAgeLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _age?.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) return context.l10n.fitnessValidationRequired;
                final age = int.tryParse(value);
                if (age == null || age < 13 || age > 100) {
                  return context.l10n.fitnessValidationAge;
                }
                return null;
              },
              onChanged: (value) => _age = int.tryParse(value),
            ),
            const SizedBox(height: 16),

            Text(
              context.l10n.fitnessQuestionnaireSexLabel,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<BiologicalSex>(
              segments: [
                ButtonSegment(
                  value: BiologicalSex.male,
                  label: Text(context.l10n.fitnessQuestionnaireSexMale),
                  icon: const Icon(Icons.male),
                ),
                ButtonSegment(
                  value: BiologicalSex.female,
                  label: Text(context.l10n.fitnessQuestionnaireSexFemale),
                  icon: const Icon(Icons.female),
                ),
              ],
              selected: {_sex},
              onSelectionChanged: (set) => setState(() => _sex = set.first),
            ),

            // Feedback widget for step 1
            StepFeedbackWidget(
              stepNumber: 1,
              initialRating: ref.watch(currentQuestionnaireAnalyticsProvider)?.stepFeedback[1],
              onRatingChanged: (rating) {
                ref.read(currentQuestionnaireAnalyticsProvider.notifier)
                  .trackStepFeedback(1, rating);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _experienceKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.fitnessQuestionnaireExperienceTitle,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            Text(
              context.l10n.fitnessQuestionnaireExperienceLevelLabel,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...ExperienceLevel.values.map((level) {
              return RadioListTile<ExperienceLevel>(
                title: Text(_getExperienceLevelLabel(level)),
                value: level,
                groupValue: _experienceLevel,
                onChanged: (val) => setState(() => _experienceLevel = val!),
              );
            }),
            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireMonthsTrainingLabel,
                border: const OutlineInputBorder(),
                helperText: context.l10n.fitnessQuestionnaireMonthsHelperText,
              ),
              keyboardType: TextInputType.number,
              initialValue: _monthsOfTraining?.toString(),
              onChanged: (value) => _monthsOfTraining = int.tryParse(value),
            ),

            // Feedback widget for step 2
            StepFeedbackWidget(
              stepNumber: 2,
              initialRating: ref.watch(currentQuestionnaireAnalyticsProvider)?.stepFeedback[2],
              onRatingChanged: (rating) {
                ref.read(currentQuestionnaireAnalyticsProvider.notifier)
                  .trackStepFeedback(2, rating);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getExperienceLevelLabel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.untrained:
        return context.l10n.fitnessQuestionnaireExperienceLevelUntrained;
      case ExperienceLevel.novice:
        return context.l10n.fitnessQuestionnaireExperienceLevelNovice;
      case ExperienceLevel.intermediate:
        return context.l10n.fitnessQuestionnaireExperienceLevelIntermediate;
      case ExperienceLevel.advanced:
        return context.l10n.fitnessQuestionnaireExperienceLevelAdvanced;
      case ExperienceLevel.elite:
        return context.l10n.fitnessQuestionnaireExperienceLevelElite;
    }
  }

  Widget _buildMaxLiftsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _maxLiftsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.fitnessQuestionnaireMaxLiftsTitle,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.fitnessQuestionnaireMaxLiftsDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireBenchPressLabel,
                suffixText: 'kg',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _benchPressMax?.toString(),
              onChanged: (value) => _benchPressMax = double.tryParse(value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireSquatLabel,
                suffixText: 'kg',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _squatMax?.toString(),
              onChanged: (value) => _squatMax = double.tryParse(value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireDeadliftLabel,
                suffixText: 'kg',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _deadliftMax?.toString(),
              onChanged: (value) => _deadliftMax = double.tryParse(value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.fitnessQuestionnaireOhpLabel,
                suffixText: 'kg',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _overheadPressMax?.toString(),
              onChanged: (value) => _overheadPressMax = double.tryParse(value),
            ),

            // Feedback widget for step 3
            StepFeedbackWidget(
              stepNumber: 3,
              initialRating: ref.watch(currentQuestionnaireAnalyticsProvider)?.stepFeedback[3],
              onRatingChanged: (rating) {
                ref.read(currentQuestionnaireAnalyticsProvider.notifier)
                  .trackStepFeedback(3, rating);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _injuryKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.fitnessInjuryHistoryTitle,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            CheckboxListTile(
              title: Text(context.l10n.fitnessQuestionnaireInjuryHistoryLabel),
              value: _hasInjuryHistory,
              onChanged: (val) => setState(() => _hasInjuryHistory = val ?? false),
              contentPadding: EdgeInsets.zero,
            ),

            if (_hasInjuryHistory) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: context.l10n.fitnessInjuryType,
                  hintText: context.l10n.fitnessInjuryTypeHint,
                  border: const OutlineInputBorder(),
                ),
                initialValue: _injuryType,
                onChanged: (value) => _injuryType = value,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<InjuryRegion>(
                decoration: InputDecoration(
                  labelText: context.l10n.fitnessInjuryBodyRegion,
                  border: const OutlineInputBorder(),
                ),
                initialValue: _injuryRegion,
                items: InjuryRegion.values.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region.getLabel(Localizations.localeOf(context).languageCode)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _injuryRegion = val),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: context.l10n.fitnessInjuryMonthsSince,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _monthsSinceInjury?.toString(),
                onChanged: (value) => _monthsSinceInjury = int.tryParse(value),
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: Text(context.l10n.fitnessQuestionnaireFullyRecovered),
                value: _fullyRecovered,
                onChanged: (val) => setState(() => _fullyRecovered = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),

              CheckboxListTile(
                title: Text(context.l10n.fitnessQuestionnaireInRehabilitation),
                value: _inRehabilitation,
                onChanged: (val) => setState(() => _inRehabilitation = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),
              Text(
                '${context.l10n.fitnessQuestionnaireCurrentPainLevel}: $_currentPainLevel/10',
                style: context.textTheme.titleSmall,
              ),
              Slider(
                value: _currentPainLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: _currentPainLevel.toString(),
                onChanged: (val) => setState(() => _currentPainLevel = val.toInt()),
              ),
            ],

            // Feedback widget for step 4
            StepFeedbackWidget(
              stepNumber: 4,
              initialRating: ref.watch(currentQuestionnaireAnalyticsProvider)?.stepFeedback[4],
              onRatingChanged: (rating) {
                ref.read(currentQuestionnaireAnalyticsProvider.notifier)
                  .trackStepFeedback(4, rating);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _goalsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.fitnessQuestionnaireGoalsTitle,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            Text(
              context.l10n.fitnessQuestionnaireTrainingGoalLabel,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...TrainingGoal.values.map((goal) {
              return RadioListTile<TrainingGoal>(
                title: Text(_getTrainingGoalLabel(goal)),
                value: goal,
                groupValue: _trainingGoal,
                onChanged: (val) => setState(() => _trainingGoal = val!),
              );
            }),
            const SizedBox(height: 16),

            Text(
              context.l10n.fitnessQuestionnaireSuggestionStyleLabel,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...SuggestionStyle.values.map((style) {
              return RadioListTile<SuggestionStyle>(
                title: Text(_getSuggestionStyleLabel(style)),
                value: style,
                groupValue: _suggestionStyle,
                onChanged: (val) => setState(() => _suggestionStyle = val!),
              );
            }),
            const SizedBox(height: 16),

            Text(
              context.l10n.fitnessQuestionnaireSelfAssessmentTitle,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.fitnessQuestionnaireSelfAssessmentDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            ...SelfReportCalibration.values.map((calibration) {
              return RadioListTile<SelfReportCalibration>(
                title: Text(calibration.getLabel(Localizations.localeOf(context).languageCode)),
                value: calibration,
                groupValue: _selfReportCalibration,
                onChanged: (val) => setState(() => _selfReportCalibration = val!),
              );
            }),

            // Feedback widget for step 5
            StepFeedbackWidget(
              stepNumber: 5,
              initialRating: ref.watch(currentQuestionnaireAnalyticsProvider)?.stepFeedback[5],
              onRatingChanged: (rating) {
                ref.read(currentQuestionnaireAnalyticsProvider.notifier)
                  .trackStepFeedback(5, rating);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getTrainingGoalLabel(TrainingGoal goal) {
    switch (goal) {
      case TrainingGoal.strength:
        return context.l10n.fitnessQuestionnaireTrainingGoalStrength;
      case TrainingGoal.hypertrophy:
        return context.l10n.fitnessQuestionnaireTrainingGoalHypertrophy;
      case TrainingGoal.endurance:
        return context.l10n.fitnessQuestionnaireTrainingGoalEndurance;
    }
  }

  String _getSuggestionStyleLabel(SuggestionStyle style) {
    switch (style) {
      case SuggestionStyle.conservative:
        return context.l10n.fitnessQuestionnaireSuggestionStyleConservative;
      case SuggestionStyle.balanced:
        return context.l10n.fitnessQuestionnaireSuggestionStyleBalanced;
      case SuggestionStyle.aggressive:
        return context.l10n.fitnessQuestionnaireSuggestionStyleAggressive;
    }
  }

  String _getSexLabel(BiologicalSex sex) {
    switch (sex) {
      case BiologicalSex.male:
        return context.l10n.fitnessQuestionnaireSexMale;
      case BiologicalSex.female:
        return context.l10n.fitnessQuestionnaireSexFemale;
    }
  }

  String _getSelfReportCalibrationLabel(SelfReportCalibration calibration) {
    return calibration.getLabel(Localizations.localeOf(context).languageCode);
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.fitnessQuestionnaireReviewTitle,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.fitnessQuestionnaireReviewDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          _buildReviewCard(context.l10n.fitnessQuestionnaireReviewDemographics, [
            '${context.l10n.fitnessQuestionnaireReviewBodyweight}: ${_bodyweightKg?.toStringAsFixed(1)} kg',
            '${context.l10n.fitnessQuestionnaireReviewAge}: $_age',
            '${context.l10n.fitnessQuestionnaireReviewSex}: ${_getSexLabel(_sex)}',
          ]),
          const SizedBox(height: 12),

          _buildReviewCard(context.l10n.fitnessQuestionnaireReviewExperience, [
            '${context.l10n.fitnessQuestionnaireReviewLevel}: ${_getExperienceLevelLabel(_experienceLevel)}',
            if (_monthsOfTraining != null) '${context.l10n.fitnessQuestionnaireReviewTraining}: $_monthsOfTraining ${context.l10n.fitnessQuestionnaireReviewMonths}',
          ]),
          const SizedBox(height: 12),

          if (_benchPressMax != null || _squatMax != null || _deadliftMax != null || _overheadPressMax != null)
            _buildReviewCard(context.l10n.fitnessQuestionnaireReviewMaxLifts, [
              if (_benchPressMax != null) '${context.l10n.fitnessQuestionnaireReviewBench}: ${_benchPressMax!.toStringAsFixed(1)} kg',
              if (_squatMax != null) '${context.l10n.fitnessQuestionnaireReviewSquat}: ${_squatMax!.toStringAsFixed(1)} kg',
              if (_deadliftMax != null) '${context.l10n.fitnessQuestionnaireReviewDeadlift}: ${_deadliftMax!.toStringAsFixed(1)} kg',
              if (_overheadPressMax != null) '${context.l10n.fitnessQuestionnaireReviewOHP}: ${_overheadPressMax!.toStringAsFixed(1)} kg',
            ]),

          const SizedBox(height: 12),
          _buildReviewCard(context.l10n.fitnessQuestionnaireReviewGoals, [
            '${context.l10n.fitnessQuestionnaireReviewTrainingGoal}: ${_getTrainingGoalLabel(_trainingGoal)}',
            '${context.l10n.fitnessQuestionnaireReviewSuggestionStyle}: ${_getSuggestionStyleLabel(_suggestionStyle)}',
            '${context.l10n.fitnessQuestionnaireReviewSelfAssessment}: ${_getSelfReportCalibrationLabel(_selfReportCalibration)}',
          ]),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }
}
