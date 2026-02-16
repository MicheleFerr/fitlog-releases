import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/gym_equipment_profiles_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/profile_detail_screen.dart';

/// Settings screen for managing gym equipment profiles
class EquipmentProfilesScreen extends ConsumerWidget {
  const EquipmentProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(gymEquipmentProfilesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.equipmentProfiles),
      ),
      body: profilesAsync.when(
        data: (profiles) => _buildProfilesList(context, ref, profiles, theme),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: CNButton(
        label: context.l10n.createProfile,
        onPressed: () => _createNewProfile(context, ref),
        style: CNButtonStyle.filled,
        height: 48,
        tint: context.colors.primary,
      ),
    );
  }

  Widget _buildProfilesList(
    BuildContext context,
    WidgetRef ref,
    List<GymEquipmentProfile> profiles,
    ThemeData theme,
  ) {
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: 'No profiles',
              size: AppIconSize.emptyState,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.equipmentProfiles,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      children: [
        // Tip card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              SemanticIcon(
                icon: AppIcons.lightbulb,
                semanticLabel: 'Tip',
                size: AppIconSize.small,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.quickCreateTip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            context.l10n.equipmentProfiles,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Profile cards
        ...profiles.map((profile) => _ProfileCard(
              profile: profile,
              onTap: () => _editProfile(context, ref, profile),
            )),
      ],
    );
  }

  void _createNewProfile(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileDetailScreen(),
      ),
    );
  }

  void _editProfile(
    BuildContext context,
    WidgetRef ref,
    GymEquipmentProfile profile,
  ) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(profile: profile),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onTap,
  });

  final GymEquipmentProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: SemanticIcon(
            icon: profile.isDefault ? AppIcons.home : AppIcons.location,
            semanticLabel: profile.name,
            size: AppIconSize.small,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Text(
              profile.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (profile.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.defaultProfile,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          _buildSubtitle(context),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const SemanticIcon(
          icon: AppIcons.chevronRight,
          semanticLabel: 'Open',
          size: AppIconSize.small,
        ),
        onTap: onTap,
      ),
    );
  }

  String _buildSubtitle(BuildContext context) {
    final barbellStr = profile.defaultBarbellWeight != null
        ? '${profile.defaultBarbellWeight}kg'
        : context.l10n.noBarbell;
    final platesCount = profile.availablePlates.length;
    return '$barbellStr • $platesCount ${context.l10n.availablePlatesTitle.toLowerCase()}';
  }
}
