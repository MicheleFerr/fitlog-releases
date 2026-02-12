/// Athletes List Screen
///
/// Displays the list of athletes for a coach.
/// Shows sections: In Training, Workout Today, Rest Day.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/widgets/athlete_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Filter type for athletes list
enum AthleteFilter { all, active, paused }

/// Athletes list screen for coaches
class AthletesListScreen extends ConsumerStatefulWidget {
  const AthletesListScreen({super.key});

  @override
  ConsumerState<AthletesListScreen> createState() => _AthletesListScreenState();
}

class _AthletesListScreenState extends ConsumerState<AthletesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  AthleteFilter _currentFilter = AthleteFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final athletesAsync = ref.watch(athletesListProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.athletes),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.personAdd),
            onPressed: _showAddAthleteSheet,
            tooltip: context.l10n.addAthlete,
          ),
        ],
      ),
      body: athletesAsync.when(
        data: (athletes) => _buildContent(context, athletes),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CoachRelationship> athletes) {
    if (athletes.isEmpty) {
      return _buildEmptyState(context);
    }

    // Apply filters
    final filteredAthletes = _filterAthletes(athletes);

    return CustomScrollView(
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildSearchBar(context),
          ),
        ),

        // Filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _buildFilterChips(context),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Athletes sections
        ..._buildAthleteSections(context, filteredAthletes),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EnhancedEmptyState(
      icon: AppIcons.peopleOutline,
      title: context.l10n.noAthletesYet,
      description: context.l10n.addYourFirstAthlete,
      primaryActionLabel: context.l10n.addAthlete,
      onPrimaryAction: _showAddAthleteSheet,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: context.l10n.searchAthlete,
        prefixIcon: const Icon(AppIcons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(AppIcons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                tooltip: context.l10n.clear,
              )
            : null,
        filled: true,
        fillColor: context.colors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        FilterChip(
          label: Text(context.l10n.allAthletes),
          selected: _currentFilter == AthleteFilter.all,
          onSelected: (_) => setState(() => _currentFilter = AthleteFilter.all),
        ),
        FilterChip(
          label: Text(context.l10n.activeAthletes),
          selected: _currentFilter == AthleteFilter.active,
          onSelected: (_) =>
              setState(() => _currentFilter = AthleteFilter.active),
        ),
        FilterChip(
          label: Text(context.l10n.pausedAthletes),
          selected: _currentFilter == AthleteFilter.paused,
          onSelected: (_) =>
              setState(() => _currentFilter = AthleteFilter.paused),
        ),
      ],
    );
  }

  List<CoachRelationship> _filterAthletes(List<CoachRelationship> athletes) {
    var filtered = athletes;

    // Apply status filter
    switch (_currentFilter) {
      case AthleteFilter.all:
        break;
      case AthleteFilter.active:
        filtered = filtered.where((a) => a.isActive).toList();
      case AthleteFilter.paused:
        filtered = filtered
            .where((a) => a.status == RelationshipStatus.paused)
            .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (a) =>
                (a.athleteName?.toLowerCase().contains(query) ?? false) ||
                (a.athleteEmail?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  List<Widget> _buildAthleteSections(
    BuildContext context,
    List<CoachRelationship> athletes,
  ) {
    // For now, just show all athletes in a single list
    // TODO: In future, categorize by: In Training, Workout Today, Rest Day
    // This requires integration with workout scheduling

    if (athletes.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                context.l10n.noAthletesYet,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        sliver: SliverList.separated(
          itemCount: athletes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final athlete = athletes[index];
            return AthleteCard(
              relationship: athlete,
              onTap: () => _navigateToAthleteProfile(athlete),
              // TODO: Get actual workout status from workout scheduling
              workoutStatus: AthleteWorkoutStatus.restDay,
            );
          },
        ),
      ),
    ];
  }

  void _navigateToAthleteProfile(CoachRelationship athlete) {
    context.pushNamed(
      AppRoutes.athleteDetailName,
      pathParameters: {'athleteId': athlete.athleteId},
      queryParameters: {'name': athlete.athleteName ?? ''},
    );
  }

  void _showAddAthleteSheet() {
    ModalService.showSheet(context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _AddAthleteSheet(),
    );
  }
}

/// Bottom sheet for adding a new athlete
class _AddAthleteSheet extends ConsumerWidget {
  const _AddAthleteSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachCodeAsync = ref.watch(coachCodeProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                context.l10n.addAthlete,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Option 1: Share code
              _buildShareCodeCard(context, ref, coachCodeAsync),
              const SizedBox(height: AppSpacing.md),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      context.l10n.orDivider,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Option 2: Create manual profile (future feature)
              _buildManualProfileCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareCodeCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<String?> coachCodeAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.shareOutlined,
                color: context.colors.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.shareCode,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.athleteDownloadsApp,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Coach code display
          coachCodeAsync.when(
            data: (code) => code != null
                ? _CoachCodeDisplay(code: code)
                : const SizedBox.shrink(),
            loading: () => const Center(child: LoadingIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildManualProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.personAdd, color: context.colors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.createManualProfile,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.forAthletesNotUsingApp,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement manual profile creation
                Navigator.of(context).pop();
              },
              child: Text(context.l10n.createProfile),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display and share coach code
class _CoachCodeDisplay extends StatelessWidget {
  const _CoachCodeDisplay({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Code display
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            code,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyCode(context),
                icon: const Icon(AppIcons.copy, size: 18),
                label: Text(context.l10n.copyCode),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              // Accessibility: Share code button with semantic label
              child: Semantics(
                label: context.l10n.shareCode,
                button: true,
                child: FilledButton.icon(
                  onPressed: () => _shareCode(context),
                  icon: const Icon(AppIcons.share, size: 18),
                  label: Text(context.l10n.shareCode),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    SnackBarService.showSuccess(context, context.l10n.codeCopied);
  }

  void _shareCode(BuildContext context) {
    final message = context.l10n.shareCodeMessage(code);
    share_plus.SharePlus.instance.share(share_plus.ShareParams(text: message));
  }
}
