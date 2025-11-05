/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/zen_mode_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/zen_mode_settings_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_actions/template_save_helper.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class WorkoutSettingsMenu extends ConsumerWidget {

  const WorkoutSettingsMenu({
    super.key,
    required this.currentWorkout,
    this.onCompleteWorkout,
  });
  final Workout? currentWorkout;
  final VoidCallback? onCompleteWorkout;

  static void show(
    BuildContext context, {
    Workout? currentWorkout,
    VoidCallback? onCompleteWorkout,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WorkoutSettingsMenu(
        currentWorkout: currentWorkout,
        onCompleteWorkout: onCompleteWorkout,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            const SizedBox(height: 16),
            if (currentWorkout != null) ...[
              ..._buildWorkoutActions(context, ref),
              const Divider(),
            ],
            ..._buildZenModeSection(context, ref),
            const Divider(),
            ..._buildGeneralActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  List<Widget> _buildWorkoutActions(BuildContext context, WidgetRef ref) {
    return [
      ListTile(
        leading: const Icon(Icons.save_alt),
        title: Text(AppLocalizations.of(context).saveAsTemplate),
        subtitle: Text(AppLocalizations.of(context).saveToFirebaseForReuse),
        onTap: () {
          Navigator.pop(context);
          TemplateSaveHelper.showSaveAsTemplateDialog(context, ref);
        },
      ),
      ListTile(
        leading: const Icon(Icons.pause),
        title: Text(AppLocalizations.of(context).pauseWorkout),
        onTap: () {
          ref.read(currentWorkoutProvider.notifier).pauseWorkout();
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(
          Icons.stop,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(AppLocalizations.of(context).endWorkout),
        onTap: () {
          Navigator.pop(context);
          if (onCompleteWorkout != null) {
            onCompleteWorkout!();
          }
        },
      ),
    ];
  }

  List<Widget> _buildZenModeSection(BuildContext context, WidgetRef ref) {
    return [
      Consumer(
        builder: (context, ref, _) {
          final zenState = ref.watch(zenModeProvider);
          final zenNotifier = ref.read(zenModeProvider.notifier);
          
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.self_improvement,
                  color: zenState.isEnabled 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
                ),
                title: Text(AppLocalizations.of(context).zenMode),
                subtitle: Text(
                  zenState.isEnabled 
                    ? AppLocalizations.of(context).zenModeActiveDescription
                    : AppLocalizations.of(context).zenModeInactiveDescription,
                ),
                trailing: Switch.adaptive(
                  value: zenState.isEnabled,
                  onChanged: (_) => zenNotifier.toggleZenMode(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => const ZenModeSettingsDialog(),
                  );
                },
              ),
              if (currentWorkout != null)
                ListTile(
                  leading: Icon(
                    AppIcons.mobileScreenShare,
                    color: zenState.isKeepScreenOnActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  ),
                  title: Text(AppLocalizations.of(context).keepScreenOn),
                  subtitle: Text(
                    zenState.isKeepScreenOnActive
                      ? AppLocalizations.of(context).screenWontTurnOff
                      : AppLocalizations.of(context).batterySaverActive,
                  ),
                  trailing: Switch.adaptive(
                    value: zenState.isKeepScreenOnActive,
                    onChanged: (_) => zenNotifier.toggleKeepScreenOn(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }

  List<Widget> _buildGeneralActions(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(AppIcons.tune),
        title: Text(AppLocalizations.of(context).customizeWorkout),
        subtitle: Text(AppLocalizations.of(context).rpeTimerAndMore),
        onTap: () {
          Navigator.pop(context);
          WorkoutCustomizationModalV3.show(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: Text(AppLocalizations.of(context).signOut),
        onTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
      ),
    ];
  }
}