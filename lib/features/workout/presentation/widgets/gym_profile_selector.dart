import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/gym_equipment_profiles_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(allGymEquipmentProfilesProvider);
    final activeProfileAsync = ref.watch(activeGymEquipmentProfileProvider);

    return profilesAsync.when(
      data: (profiles) {
        final activeProfile = activeProfileAsync.value;

        return PopupMenuButton<_ProfileAction>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            // Profile list
            ...profiles.map((profile) => PopupMenuItem<_ProfileAction>(
                  value: _ProfileAction.select(profile),
                  child: Row(
                    children: [
                      SemanticIcon(
                        icon: profile.isDefault
                            ? AppIcons.home
                            : AppIcons.location,
                        semanticLabel: profile.name,
                        size: AppIconSize.small,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: activeProfile?.id == profile.id
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (activeProfile?.id == profile.id)
                        SemanticIcon(
                          icon: AppIcons.check,
                          semanticLabel: 'Selected',
                          size: AppIconSize.tiny,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                )),

            // Divider
            const PopupMenuDivider(),

            // New profile action
            PopupMenuItem<_ProfileAction>(
              value: _ProfileAction.newProfile(),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.add,
                    semanticLabel: context.l10n.newProfile,
                    size: AppIconSize.small,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.newProfile,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Manage profiles action
            PopupMenuItem<_ProfileAction>(
              value: _ProfileAction.manage(),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.settings,
                    semanticLabel: context.l10n.manageProfiles,
                    size: AppIconSize.small,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.manageProfiles,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (action) {
            HapticFeedback.selectionClick();

            switch (action.type) {
              case _ActionType.select:
                if (action.profile != null) {
                  ref.read(selectedProfileIdProvider.notifier).state =
                      action.profile!.id;
                  onProfileChanged?.call(action.profile!);
                }
              case _ActionType.newProfile:
                onNewProfileTapped?.call();
              case _ActionType.manage:
                onManageProfilesTapped?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SemanticIcon(
                  icon: AppIcons.location,
                  semanticLabel: 'Profile',
                  size: AppIconSize.tiny,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  activeProfile?.name ?? context.l10n.defaultProfile,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                SemanticIcon(
                  icon: AppIcons.expandMore,
                  semanticLabel: 'Expand',
                  size: AppIconSize.tiny,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

enum _ActionType { select, newProfile, manage }

class _ProfileAction {
  _ProfileAction._(this.type, [this.profile]);

  factory _ProfileAction.select(GymEquipmentProfile profile) =>
      _ProfileAction._(_ActionType.select, profile);

  factory _ProfileAction.newProfile() =>
      _ProfileAction._(_ActionType.newProfile);

  factory _ProfileAction.manage() => _ProfileAction._(_ActionType.manage);

  final _ActionType type;
  final GymEquipmentProfile? profile;
}
