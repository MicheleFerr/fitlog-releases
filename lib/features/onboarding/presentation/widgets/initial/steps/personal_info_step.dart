import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/initial_onboarding_style.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Step 2: Personal Info - Sex selection + Age picker (Yazio-inspired)
class PersonalInfoStep extends ConsumerStatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep> {
  static const int _minAge = 14;
  static const int _maxAge = 80;
  static const int _defaultAge = 25;
  static const String _maleAvatarPath = 'assets/images/sex_male_no_bg.png';
  static const String _femaleAvatarPath = 'assets/images/sex_female_no_bg.png';

  late FixedExtentScrollController _ageController;

  @override
  void initState() {
    super.initState();
    final currentAge = ref.read(initialOnboardingNotifierProvider).age;
    final initialIndex = (currentAge ?? _defaultAge) - _minAge;
    _ageController = FixedExtentScrollController(initialItem: initialIndex);

    // Set default age if not already set
    if (currentAge == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(initialOnboardingNotifierProvider.notifier)
            .setAge(_defaultAge);
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(initialOnboardingNotifierProvider);
    final notifier = ref.read(initialOnboardingNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: InitialOnboardingStyle.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: InitialOnboardingStyle.topSpacing),

          // Title
          Text(
            context.l10n.initialOnboardingPersonalInfoTitle,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.l10n.initialOnboardingPersonalInfoSubtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 40),

          // Sex selection label
          Text(
            context.l10n.initialOnboardingSexLabel,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Sex cards - large 50/50
          Row(
            children: [
              Expanded(
                child: _SexCard(
                  assetPath: _maleAvatarPath,
                  fallbackEmoji: '\u{1F468}', // 👨
                  label: context.l10n.initialOnboardingSexMale,
                  isSelected: state.sex == BiologicalSex.male,
                  onTap: () => notifier.setSex(BiologicalSex.male),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SexCard(
                  assetPath: _femaleAvatarPath,
                  fallbackEmoji: '\u{1F469}', // 👩
                  label: context.l10n.initialOnboardingSexFemale,
                  isSelected: state.sex == BiologicalSex.female,
                  onTap: () => notifier.setSex(BiologicalSex.female),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Age label
          Text(
            context.l10n.initialOnboardingAgeLabel,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // CupertinoPicker for age
          SizedBox(
            height: 180,
            child: CupertinoPicker(
              scrollController: _ageController,
              itemExtent: 44,
              diameterRatio: 1.2,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                notifier.setAge(_minAge + index);
              },
              children: List.generate(_maxAge - _minAge + 1, (index) {
                final age = _minAge + index;
                final isSelected = age == (state.age ?? _defaultAge);
                return Center(
                  child: Text(
                    '$age ${context.l10n.initialOnboardingAgeYears}',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }),
            ),
          ),

          const Spacer(),

          // Continue button
          // Accessibility: Semantic label for screen readers
          Semantics(
            label: context.l10n.initialOnboardingContinue,
            button: true,
            child: FilledButton(
              onPressed: state.canProceedFromStep(2)
                  ? () => notifier.nextStep()
                  : null,
              style: InitialOnboardingStyle.primaryButtonStyle(context),
              child: Text(context.l10n.initialOnboardingContinue),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Large sex selection card
class _SexCard extends StatelessWidget {
  const _SexCard({
    required this.assetPath,
    required this.fallbackEmoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String assetPath;
  final String fallbackEmoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedBorderColor = Color(0xFF22C55E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(
            InitialOnboardingStyle.cardRadius,
          ),
          border: Border.all(
            color: isSelected
                ? selectedBorderColor
                : context.colors.outline.withValues(alpha: 0.28),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              assetPath,
              width: 92,
              height: 92,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Text(fallbackEmoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
