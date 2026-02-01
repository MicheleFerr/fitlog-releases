import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

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
        ref.read(initialOnboardingNotifierProvider.notifier).setAge(_defaultAge);
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

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
                  emoji: '\u{1F468}', // 👨
                  label: context.l10n.initialOnboardingSexMale,
                  isSelected: state.sex == BiologicalSex.male,
                  onTap: () => notifier.setSex(BiologicalSex.male),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SexCard(
                  emoji: '\u{1F469}', // 👩
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
              children: List.generate(
                _maxAge - _minAge + 1,
                (index) {
                  final age = _minAge + index;
                  final isSelected = age == (state.age ?? _defaultAge);
                  return Center(
                    child: Text(
                      '$age ${context.l10n.initialOnboardingAgeYears}',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const Spacer(),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.canProceedFromStep(2)
                  ? () => notifier.nextStep()
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.initialOnboardingContinue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurface,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                AppIcons.checkCircle,
                color: context.colors.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
