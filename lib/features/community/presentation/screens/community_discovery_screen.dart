/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/screens
/// 🎯 Feature: community discovery
/// 🔧 Type: screen
///
/// Community Discovery Screen - Browse and search community contributions
///
/// Features:
/// - Full-text search with real-time updates
/// - Multiple filters (type, difficulty, author tier, date range)
/// - Sort options (helpful, recent, saved, trending)
/// - Empty state and error handling
/// - Apple HIG compliant design
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/contribution_card.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/filters_modal.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/sort_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class CommunityDiscoveryScreen extends ConsumerStatefulWidget {
  const CommunityDiscoveryScreen({super.key});

  @override
  ConsumerState<CommunityDiscoveryScreen> createState() =>
      _CommunityDiscoveryScreenState();
}

class _CommunityDiscoveryScreenState
    extends ConsumerState<CommunityDiscoveryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ ADMIN-ONLY CHECK
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        // 🐛 DEBUG: Log admin check
        if (kDebugMode) {
          debugPrint('🔍 [CommunityDiscovery] userProfile: ${userProfile?.uid}');
          debugPrint('🔍 [CommunityDiscovery] isAdmin: ${userProfile?.isAdmin}');
          debugPrint('🔍 [CommunityDiscovery] userProfile == null: ${userProfile == null}');
        }

        // Check if user is admin
        if (userProfile == null || !userProfile.isAdmin) {
          if (kDebugMode) {
            debugPrint('❌ [CommunityDiscovery] Access DENIED - Not admin');
          }
          return _buildAdminOnlyScreen(context);
        }

        if (kDebugMode) {
          debugPrint('✅ [CommunityDiscovery] Access GRANTED - Is admin');
        }

        // Admin user - show community
        final searchResults = ref.watch(searchResultsProvider);
        final activeFilters = ref.watch(activeFiltersProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.discover),
            elevation: 0,
            actions: [
              // Admin badge
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colors.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.shield,
                          size: AppIconSize.small,
                          color: context.colors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              _buildSearchBar(),

              // Filters & Sort Row
              _buildFiltersRow(activeFilters),

              // Results List
              Expanded(
                child: searchResults.when(
                  data: (contributions) => _buildResultsList(contributions),
                  loading: () => const LoadingIndicator(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error loading user profile: $error'),
        ),
      ),
    );
  }

  /// Admin-only screen (non-admin users)
  Widget _buildAdminOnlyScreen(BuildContext context) {
    // Get current userProfile for debug info
    final userProfileAsync = ref.watch(userProfileProvider);
    final userProfile = userProfileAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.discover),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.shield,
                size: AppIconSize.xxlarge * 2,
                color: context.colors.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'Admin Only',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This feature is currently restricted to administrators only.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Community discovery and contributions will be available to all users soon.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                ),
              ),

              // 🐛 DEBUG INFO (only in debug mode)
              if (kDebugMode) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🐛 DEBUG INFO',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'UserProfile: ${userProfile == null ? "NULL ❌" : "✅ Loaded"}',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (userProfile != null) ...[
                        Text(
                          'UID: ${userProfile.uid}',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'isAdmin: ${userProfile.isAdmin ? "✅ true" : "❌ false"}',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: userProfile.isAdmin
                                ? context.colors.primary
                                : context.colors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'To fix: Set isAdmin=true in Firestore',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        'Path: users/{uid}/isAdmin',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontFamily: 'monospace',
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.searchContributions,
          prefixIcon: Icon(
            AppIcons.search,
            color: context.colors.onSurfaceVariant,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    AppIcons.clear,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {}); // Update UI to hide clear button
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: context.colors.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
          setState(() {}); // Update UI for clear button visibility
        },
      ),
    );
  }

  Widget _buildFiltersRow(ContributionFilters filters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Filters Button
          OutlinedButton.icon(
            onPressed: () => FiltersModal.show(context),
            icon: Icon(
              AppIcons.filter,
              size: 20,
              color: context.colors.primary,
            ),
            label: Text(
              context.l10n.filters,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Sort Button
          OutlinedButton.icon(
            onPressed: () => SortModal.show(context),
            icon: Icon(
              AppIcons.sort,
              size: 20,
              color: context.colors.primary,
            ),
            label: Text(
              context.l10n.sort,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),

          const Spacer(),

          // Active Filters Count Badge (if any)
          if (_hasActiveFilters(filters))
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_countActiveFilters(filters)}',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<CommunityContribution> contributions) {
    if (contributions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: contributions.length,
      itemBuilder: (context, index) {
        return ContributionCard(contribution: contributions[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.searchOff,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noContributionsFound,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tryDifferentSearch,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingContributions,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters(ContributionFilters filters) {
    return filters.exerciseIds.isNotEmpty ||
        filters.type != null ||
        filters.difficulty != null ||
        filters.authorTier != null ||
        filters.dateFrom != null ||
        filters.dateTo != null;
  }

  int _countActiveFilters(ContributionFilters filters) {
    int count = 0;
    if (filters.exerciseIds.isNotEmpty) count++;
    if (filters.type != null) count++;
    if (filters.difficulty != null) count++;
    if (filters.authorTier != null) count++;
    if (filters.dateFrom != null || filters.dateTo != null) count++;
    return count;
  }
}
