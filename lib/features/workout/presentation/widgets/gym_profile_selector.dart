import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/gym_equipment_profiles_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:cupertino_native/cupertino_native.dart';

/// Dropdown selector for switching between gym equipment profiles
class GymProfileSelector extends ConsumerWidget {
  const GymProfileSelector({
    super.key,
    this.onNewProfileTapped,
    this.onManageProfilesTapped,
    this.onProfileChanged,
  });

  final VoidCallback? onNewProfileTapped;
  final VoidCallback? onManageProfilesTapped;
  final ValueChanged<GymEquipmentProfile>? onProfileChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(allGymEquipmentProfilesProvider);
    final activeProfileAsync = ref.watch(activeGymEquipmentProfileProvider);

    return profilesAsync.when(
      data: (profiles) {
        final activeProfile = activeProfileAsync.value;

        return CNPopupMenuButton(
          buttonLabel: activeProfile?.name ?? context.l10n.defaultProfile,
          buttonStyle: CNButtonStyle.glass,
          shrinkWrap: true,
          height: 36,
          items: [
            // Profile list
            ...profiles.map((profile) => CNPopupMenuItem(
                  label: profile.name,
                  icon: CNSymbol(
                    activeProfile?.id == profile.id
                        ? 'checkmark'
                        : (profile.isDefault ? 'house' : 'mappin.and.ellipse'),
                    size: 14,
                  ),
                )),

            // New profile action
            CNPopupMenuItem(
              label: context.l10n.newProfile,
              icon: const CNSymbol('plus', size: 14),
            ),

            // Manage profiles action
            CNPopupMenuItem(
              label: context.l10n.manageProfiles,
              icon: const CNSymbol('gearshape', size: 14),
            ),
          ],
          onSelected: (index) {
            HapticFeedback.selectionClick();

            if (index < profiles.length) {
              // Profile selected
              final profile = profiles[index];
              ref.read(selectedProfileIdProvider.notifier).state = profile.id;
              onProfileChanged?.call(profile);
            } else if (index == profiles.length) {
              // New profile
              onNewProfileTapped?.call();
            } else if (index == profiles.length + 1) {
              // Manage profiles
              onManageProfilesTapped?.call();
            }
          },
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const LoadingIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

