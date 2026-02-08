import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/providers/progress_photo_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for configuring photo reminder settings
///
/// UX based on competitor research:
/// - Simple toggle for enable/disable
/// - Recommended frequency highlighted (4 weeks per Hevy research)
/// - Clear next reminder preview
/// - Anti-spam explanation
class PhotoReminderSettingsSheet extends ConsumerStatefulWidget {
  const PhotoReminderSettingsSheet({super.key});

  @override
  ConsumerState<PhotoReminderSettingsSheet> createState() =>
      _PhotoReminderSettingsSheetState();
}

class _PhotoReminderSettingsSheetState
    extends ConsumerState<PhotoReminderSettingsSheet> {
  TimeOfDay? _selectedTime;
  PhotoReminderFrequency? _selectedFrequency;

  @override
  Widget build(BuildContext context) {
    final reminderAsync = ref.watch(photoReminderProviderAsync);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: reminderAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: LoadingIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.error, size: 48, color: context.colors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load reminder settings',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(photoReminderProviderAsync),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
          data: (notifier) => _buildContent(context, notifier),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PhotoReminderNotifier notifier) {
    // Get settings from repository directly (notifier.state is protected)
    final settingsAsync = ref.watch(photoReminderSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) => _buildSettingsContent(context, notifier, settings),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    PhotoReminderNotifier notifier,
    PhotoReminderSettings settings,
  ) {
    final isEnabled = settings.isEnabled;

    // Initialize local state from settings
    _selectedTime ??= settings.reminderTime;
    _selectedFrequency ??= settings.frequency;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Enable toggle
            _buildEnableToggle(context, notifier, isEnabled),
            const SizedBox(height: 24),

            // Settings (only if enabled)
            if (isEnabled) ...[
              // Frequency selector
              _buildFrequencySelector(context, notifier, settings),
              const SizedBox(height: 20),

              // Time selector
              _buildTimeSelector(context, notifier, settings),
              const SizedBox(height: 20),

              // Next reminder preview
              _buildNextReminderPreview(context, settings),
              const SizedBox(height: 16),

              // Anti-spam info
              _buildAntiSpamInfo(context, settings),
            ],

            // Disabled by anti-spam message
            if (settings.disabledByAntiSpam) ...[
              const SizedBox(height: 16),
              _buildDisabledByAntiSpamMessage(context),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppIcons.notifications,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.photoReminders,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                context.l10n.photoRemindersDescription,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnableToggle(
    BuildContext context,
    PhotoReminderNotifier notifier,
    bool isEnabled,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled
            ? context.colors.primaryContainer.withValues(alpha: 0.3)
            : context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: isEnabled
            ? Border.all(color: context.colors.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            isEnabled
                ? AppIcons.notificationsActive
                : AppIcons.notificationsNone,
            color: isEnabled
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.enablePhotoReminders,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isEnabled
                      ? context.l10n.remindersEnabled
                      : context.l10n.remindersDisabled,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (value) async {
              if (value) {
                await notifier.enableReminders(
                  frequency:
                      _selectedFrequency ?? PhotoReminderFrequency.monthly,
                  hour: _selectedTime?.hour ?? 9,
                  minute: _selectedTime?.minute ?? 0,
                );
              } else {
                await notifier.disableReminders();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector(
    BuildContext context,
    PhotoReminderNotifier notifier,
    PhotoReminderSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reminderFrequency,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PhotoReminderFrequency.values
              .where((f) => f != PhotoReminderFrequency.custom)
              .map(
                (frequency) => _buildFrequencyChip(
                  context,
                  notifier,
                  frequency,
                  settings.frequency == frequency,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencyChip(
    BuildContext context,
    PhotoReminderNotifier notifier,
    PhotoReminderFrequency frequency,
    bool isSelected,
  ) {
    final isRecommended = frequency.isRecommended;
    final label = _getFrequencyLabel(context, frequency);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isRecommended) ...[
            const SizedBox(width: 4),
            Icon(
              AppIcons.star,
              size: 14,
              color: isSelected
                  ? context.colors.onPrimary
                  : context.colors.primary,
            ),
          ],
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFrequency = frequency);
          notifier.updateFrequency(frequency);
        }
      },
      selectedColor: context.colors.primary,
      checkmarkColor: context.colors.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? context.colors.onPrimary
            : context.colors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    PhotoReminderNotifier notifier,
    PhotoReminderSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reminderTime,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectTime(context, notifier, settings),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(AppIcons.schedule, color: context.colors.primary),
                const SizedBox(width: 16),
                Text(
                  settings.formattedReminderTime,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  AppIcons.edit,
                  color: context.colors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    PhotoReminderNotifier notifier,
    PhotoReminderSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: context.colors),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _selectedTime = time);
      await notifier.updateReminderTime(time.hour, time.minute);
    }
  }

  Widget _buildNextReminderPreview(
    BuildContext context,
    PhotoReminderSettings settings,
  ) {
    final nextReminder = settings.nextReminderScheduled;
    if (nextReminder == null) return const SizedBox.shrink();

    final formattedDate = DateFormat.yMMMd().format(nextReminder);
    final formattedTime = DateFormat.Hm().format(nextReminder);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(AppIcons.event, color: context.colors.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.nextReminder,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
                Text(
                  '$formattedDate at $formattedTime',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntiSpamInfo(
    BuildContext context,
    PhotoReminderSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(AppIcons.info, size: 16, color: context.colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.photoReminderAntiSpamInfo,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledByAntiSpamMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.warningContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(AppIcons.warning, color: context.colors.warning),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.remindersAutoPaused,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onWarningContainer,
                  ),
                ),
                Text(
                  context.l10n.remindersAutoPausedDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onWarningContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyLabel(
    BuildContext context,
    PhotoReminderFrequency frequency,
  ) {
    return switch (frequency) {
      PhotoReminderFrequency.biweekly => context.l10n.everyTwoWeeks,
      PhotoReminderFrequency.monthly => context.l10n.everyFourWeeks,
      PhotoReminderFrequency.sixWeeks => context.l10n.everySixWeeks,
      PhotoReminderFrequency.custom => context.l10n.customInterval,
    };
  }
}
