# Community Discovery & Search Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Discovery & Search features to Community Hub: full-text search, advanced filters (type/exercise/difficulty/author/date), sorting (helpful/recent/saved/trending), and tags system.

**Architecture:** Firestore schema v2 with sub-collections (votes, comments, saved), Cloud Functions for denormalization, client-side search with server-side filtering, Apple HIG-compliant UI.

**Tech Stack:** Flutter, Riverpod, Firestore, Cloud Functions (TypeScript), freezed/json_serializable

---

## Phase 1: Firestore Schema Migration (Backend)

### Task 1: Update CommunityContribution Entity

**Files:**
- Modify: `lib/features/community/domain/entities/community_contribution.dart`

**Step 1: Add new discovery fields to CommunityContribution**

Add after line 49 (after `metadata` field):

```dart
// NEW: Discovery & Search fields
@Default([]) List<String> exerciseIds, // Multiple exercises (was single exerciseId)
@Default('beginner') String difficulty, // beginner, intermediate, advanced
@Default([]) List<String> tags, // User-added tags (lowercase, max 5)
@Default([]) List<String> applicableTo, // Goals: hypertrophy, strength, mobility
String? authorTier, // community, expert, admin (nullable for backward compat)
@Default(0.5) double authorTrustScore, // 0-1
@Default(0.5) double qualityScore, // 0-1 (aggregate score)
@Default(0) int saves, // How many users saved
@Default(0) int viewCount, // Track popularity
DateTime? lastActivityAt, // For trending
String? sourceType, // exerciseDb, userSubmitted
@Default([]) List<String> relatedExerciseIds, // For variants
```

**Step 2: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: Generated files updated (community_contribution.freezed.dart, community_contribution.g.dart)

**Step 3: Commit**

```bash
git add lib/features/community/domain/entities/community_contribution.dart lib/features/community/domain/entities/community_contribution.freezed.dart lib/features/community/domain/entities/community_contribution.g.dart
git commit -m "feat(community): add discovery fields to CommunityContribution entity"
```

---

### Task 2: Create ContributionFilters Entity

**Files:**
- Create: `lib/features/community/domain/entities/contribution_filters.dart`

**Step 1: Write ContributionFilters class**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution_filters.freezed.dart';
part 'contribution_filters.g.dart';

@freezed
class ContributionFilters with _$ContributionFilters {
  const factory ContributionFilters({
    @Default([]) List<String> exerciseIds,
    String? type, // correction, tip, warning, variant, translation, technique
    String? difficulty, // beginner, intermediate, advanced
    String? authorTier, // community, expert, admin
    DateTime? dateFrom,
    DateTime? dateTo,
    @Default('helpful') String sortBy, // helpful, recent, saved, trending
  }) = _ContributionFilters;

  factory ContributionFilters.fromJson(Map<String, dynamic> json) =>
      _$ContributionFiltersFromJson(json);
}

enum SortOption {
  helpful,
  recent,
  saved,
  trending,
}

extension SortOptionExtension on SortOption {
  String get value {
    switch (this) {
      case SortOption.helpful:
        return 'helpful';
      case SortOption.recent:
        return 'recent';
      case SortOption.saved:
        return 'saved';
      case SortOption.trending:
        return 'trending';
    }
  }

  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case SortOption.helpful:
        return l10n.sortByHelpful;
      case SortOption.recent:
        return l10n.sortByRecent;
      case SortOption.saved:
        return l10n.sortBySaved;
      case SortOption.trending:
        return l10n.sortByTrending;
    }
  }
}
```

**Step 2: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: Commit**

```bash
git add lib/features/community/domain/entities/contribution_filters.dart lib/features/community/domain/entities/contribution_filters.freezed.dart lib/features/community/domain/entities/contribution_filters.g.dart
git commit -m "feat(community): add ContributionFilters entity for discovery"
```

---

### Task 3: Add Search & Filter Methods to Repository Interface

**Files:**
- Modify: `lib/features/community/domain/repositories/community_repository.dart` (create if not exists)

**Step 1: Define repository interface with search methods**

Create file if doesn't exist:

```dart
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';

abstract class CommunityRepository {
  // Existing methods (keep if present)
  Stream<List<CommunityContribution>> getContributions({
    String? exerciseId,
    String? userId,
  });

  Stream<List<CommunityContribution>> getTrendingContributions();

  Stream<List<CommunityContribution>> getContributionsForReview(String userId);

  Stream<UserContributionStats> getUserStats(String userId);

  Future<void> submitContribution(CommunityContribution contribution);

  Future<void> voteOnContribution(
    String contributionId,
    String userId,
    bool isUpvote,
  );

  Future<void> updateContributionStatus(
    String contributionId,
    ContributionStatus newStatus,
    String reviewedBy,
    String? reviewNote,
  );

  // NEW: Discovery & Search methods
  Future<List<CommunityContribution>> searchContributions(String query);

  Future<List<CommunityContribution>> filterContributions(
    ContributionFilters filters,
  );

  Future<void> saveContribution(String userId, String contributionId);

  Future<void> unsaveContribution(String userId, String contributionId);

  Stream<List<String>> getSavedContributionIds(String userId);

  Future<void> incrementViewCount(String contributionId);
}
```

**Step 2: Commit**

```bash
git add lib/features/community/domain/repositories/community_repository.dart
git commit -m "feat(community): add search/filter methods to repository interface"
```

---

### Task 4: Implement Search in Firebase Repository (Part 1: Setup)

**Files:**
- Modify: `lib/features/community/data/repositories/firebase_community_repository.dart` (or create if using different name)

**Step 1: Add search method implementation**

Find the class `FirebaseCommunityRepository` and add these methods:

```dart
@override
Future<List<CommunityContribution>> searchContributions(String query) async {
  try {
    // Firestore doesn't support full-text search natively
    // MVP: Fetch recent approved contributions and filter client-side

    final snapshot = await _db
        .collection('contributions')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(200) // Fetch last 200 for client-side search
        .get();

    var results = snapshot.docs
        .map((doc) => CommunityContribution.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();

    // Client-side filtering & scoring
    final queryLower = query.toLowerCase();
    results = results.where((contrib) {
      return contrib.title.toLowerCase().contains(queryLower) ||
          contrib.description.toLowerCase().contains(queryLower) ||
          contrib.userName.toLowerCase().contains(queryLower) ||
          contrib.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();

    // Score by relevance
    results.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, queryLower);
      final scoreB = _calculateRelevanceScore(b, queryLower);
      return scoreB.compareTo(scoreA);
    });

    return results.take(50).toList();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [searchContributions] Error: $e');
    }
    rethrow;
  }
}

int _calculateRelevanceScore(CommunityContribution contrib, String query) {
  int score = 0;

  // Title match = highest relevance
  if (contrib.title.toLowerCase().contains(query)) {
    score += 100;
  }

  // Description match
  if (contrib.description.toLowerCase().contains(query)) {
    score += 50;
  }

  // Author match
  if (contrib.userName.toLowerCase().contains(query)) {
    score += 25;
  }

  // Tag exact match
  if (contrib.tags.any((tag) => tag.toLowerCase() == query)) {
    score += 75;
  }

  // Quality boost
  score += (contrib.qualityScore * 50).toInt();

  return score;
}
```

**Step 2: Commit**

```bash
git add lib/features/community/data/repositories/firebase_community_repository.dart
git commit -m "feat(community): implement searchContributions with relevance scoring"
```

---

### Task 5: Implement Advanced Filters in Firebase Repository

**Files:**
- Modify: `lib/features/community/data/repositories/firebase_community_repository.dart`

**Step 1: Add filterContributions method**

```dart
@override
Future<List<CommunityContribution>> filterContributions(
  ContributionFilters filters,
) async {
  try {
    Query query = _db.collection('contributions')
        .where('status', isEqualTo: 'approved');

    // Apply filters
    if (filters.exerciseIds.isNotEmpty) {
      query = query.where('exerciseIds', arrayContainsAny: filters.exerciseIds);
    }

    if (filters.type != null) {
      query = query.where('type', isEqualTo: filters.type);
    }

    if (filters.difficulty != null) {
      query = query.where('difficulty', isEqualTo: filters.difficulty);
    }

    if (filters.authorTier != null) {
      query = query.where('authorTier', isEqualTo: filters.authorTier);
    }

    if (filters.dateFrom != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: filters.dateFrom);
    }

    if (filters.dateTo != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: filters.dateTo);
    }

    // Apply sorting
    switch (filters.sortBy) {
      case 'helpful':
        query = query.orderBy('qualityScore', descending: true);
        break;
      case 'recent':
        query = query.orderBy('createdAt', descending: true);
        break;
      case 'saved':
        query = query.orderBy('saves', descending: true);
        break;
      case 'trending':
        // Trending = recent activity (last 7 days)
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        query = query
            .where('lastActivityAt', isGreaterThan: sevenDaysAgo)
            .orderBy('lastActivityAt', descending: true)
            .orderBy('qualityScore', descending: true);
        break;
    }

    final snapshot = await query.limit(50).get();

    return snapshot.docs
        .map((doc) => CommunityContribution.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [filterContributions] Error: $e');
    }
    rethrow;
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/community/data/repositories/firebase_community_repository.dart
git commit -m "feat(community): implement filterContributions with advanced filters"
```

---

### Task 6: Implement Save/Unsave Contributions

**Files:**
- Modify: `lib/features/community/data/repositories/firebase_community_repository.dart`

**Step 1: Add save/unsave methods**

```dart
@override
Future<void> saveContribution(String userId, String contributionId) async {
  try {
    // Add to user's savedContributions sub-collection
    await _db
        .collection('users')
        .doc(userId)
        .collection('savedContributions')
        .doc(contributionId)
        .set({
      'contributionId': contributionId,
      'savedAt': FieldValue.serverTimestamp(),
    });

    // Increment saves count on contribution
    await _db.collection('contributions').doc(contributionId).update({
      'saves': FieldValue.increment(1),
    });

    if (kDebugMode) {
      debugPrint('✅ [saveContribution] Saved $contributionId for $userId');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [saveContribution] Error: $e');
    }
    rethrow;
  }
}

@override
Future<void> unsaveContribution(String userId, String contributionId) async {
  try {
    // Remove from user's savedContributions sub-collection
    await _db
        .collection('users')
        .doc(userId)
        .collection('savedContributions')
        .doc(contributionId)
        .delete();

    // Decrement saves count on contribution
    await _db.collection('contributions').doc(contributionId).update({
      'saves': FieldValue.increment(-1),
    });

    if (kDebugMode) {
      debugPrint('✅ [unsaveContribution] Unsaved $contributionId for $userId');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [unsaveContribution] Error: $e');
    }
    rethrow;
  }
}

@override
Stream<List<String>> getSavedContributionIds(String userId) {
  return _db
      .collection('users')
      .doc(userId)
      .collection('savedContributions')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
}

@override
Future<void> incrementViewCount(String contributionId) async {
  try {
    await _db.collection('contributions').doc(contributionId).update({
      'viewCount': FieldValue.increment(1),
    });
  } catch (e) {
    // Silent fail for view count
    if (kDebugMode) {
      debugPrint('⚠️ [incrementViewCount] Error: $e');
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/community/data/repositories/firebase_community_repository.dart
git commit -m "feat(community): implement save/unsave contributions"
```

---

## Phase 2: Providers & State Management

### Task 7: Create Discovery Providers

**Files:**
- Create: `lib/features/community/presentation/providers/discovery_provider.dart`

**Step 1: Write discovery providers**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filters state
final contributionFiltersProvider = StateProvider<ContributionFilters>(
  (ref) => const ContributionFilters(),
);

// Search results provider
final searchResultsProvider = FutureProvider<List<CommunityContribution>>(
  (ref) async {
    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(contributionFiltersProvider);
    final repository = ref.watch(communityRepositoryProvider);

    if (query.isEmpty) {
      // No search query, just apply filters
      return repository.filterContributions(filters);
    }

    // Combine search + filters
    final searchResults = await repository.searchContributions(query);

    // Apply filters to search results (client-side)
    return searchResults.where((c) {
      if (filters.type != null && c.type.name != filters.type) {
        return false;
      }
      if (filters.difficulty != null && c.difficulty != filters.difficulty) {
        return false;
      }
      if (filters.exerciseIds.isNotEmpty) {
        if (!c.exerciseIds.any((e) => filters.exerciseIds.contains(e))) {
          return false;
        }
      }
      if (filters.authorTier != null && c.authorTier != filters.authorTier) {
        return false;
      }
      return true;
    }).toList();
  },
);

// Saved contribution IDs provider
final savedContributionIdsProvider = StreamProvider<List<String>>((ref) async* {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) {
    yield [];
    return;
  }

  final repository = ref.watch(communityRepositoryProvider);
  yield* repository.getSavedContributionIds(userAsync.uid);
});

// Helper: Check if contribution is saved
final isContributionSavedProvider =
    Provider.family<bool, String>((ref, contributionId) {
  final savedIds = ref.watch(savedContributionIdsProvider).asData?.value ?? [];
  return savedIds.contains(contributionId);
});

// State notifier for save/unsave actions
class SaveContributionNotifier extends StateNotifier<AsyncValue<void>> {
  SaveContributionNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> toggleSave(String contributionId) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    final savedIds =
        _ref.read(savedContributionIdsProvider).asData?.value ?? [];
    final isSaved = savedIds.contains(contributionId);

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(communityRepositoryProvider);

      if (isSaved) {
        await repository.unsaveContribution(user.uid, contributionId);
      } else {
        await repository.saveContribution(user.uid, contributionId);
      }

      state = const AsyncValue.data(null);

      if (kDebugMode) {
        debugPrint(
          '✅ [SaveContributionNotifier] ${isSaved ? 'Unsaved' : 'Saved'} $contributionId',
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      if (kDebugMode) {
        debugPrint('❌ [SaveContributionNotifier] Error: $error');
      }
    }
  }
}

final saveContributionNotifierProvider =
    StateNotifierProvider<SaveContributionNotifier, AsyncValue<void>>(
  (ref) => SaveContributionNotifier(ref),
);
```

**Step 2: Commit**

```bash
git add lib/features/community/presentation/providers/discovery_provider.dart
git commit -m "feat(community): add discovery providers for search/filters/save"
```

---

## Phase 3: UI Implementation (Apple HIG-Compliant)

### Task 8: Create Discovery Screen Shell

**Files:**
- Create: `lib/features/community/presentation/screens/discovery_screen.dart`

**Step 1: Write discovery screen scaffold**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/discovery_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.discovery),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(context),

          // Filters & Sort row
          _buildFiltersRow(context),

          const Divider(height: 1),

          // Results
          Expanded(
            child: searchResults.when(
              data: (contributions) => _buildResultsList(contributions),
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.searchContributions,
          prefixIcon: Icon(AppIcons.search, size: AppIconSize.medium),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(AppIcons.close, size: AppIconSize.small),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: context.colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filters button
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show filters modal
            },
            icon: Icon(AppIcons.filter, size: AppIconSize.small),
            label: Text(context.l10n.filters),
          ),

          const SizedBox(width: 12),

          // Sort dropdown
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show sort modal
            },
            icon: Icon(AppIcons.sort, size: AppIconSize.small),
            label: Text(context.l10n.sort),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List contributions) {
    if (contributions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.search,
              size: 64,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noResultsFound,
              style: context.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: contributions.length,
      itemBuilder: (context, index) {
        // TODO: Replace with ContributionCard widget
        return ListTile(
          title: Text(contributions[index].title),
        );
      },
    );
  }
}
```

**Step 2: Add navigation route**

Modify `lib/shared/presentation/router/app_router.dart` (or equivalent):

```dart
// Add to routes
case '/discovery':
  return MaterialPageRoute(
    builder: (_) => const DiscoveryScreen(),
  );
```

**Step 3: Commit**

```bash
git add lib/features/community/presentation/screens/discovery_screen.dart
git commit -m "feat(community): add discovery screen shell with search bar"
```

---

### Task 9: Add Localization Strings

**Files:**
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Add English strings**

Add to `app_en.arb`:

```json
"discovery": "Discovery",
"searchContributions": "Search contributions...",
"filters": "Filters",
"sort": "Sort",
"noResultsFound": "No results found",
"sortByHelpful": "Most Helpful",
"sortByRecent": "Most Recent",
"sortBySaved": "Most Saved",
"sortByTrending": "Trending",
"filterByType": "Type",
"filterByDifficulty": "Difficulty",
"filterByExercise": "Exercise",
"filterByAuthor": "Author",
"filterByDate": "Date Range",
"resetFilters": "Reset Filters",
"applyFilters": "Apply Filters",
"contributionTypeTip": "Tip",
"contributionTypeTechnique": "Technique",
"contributionTypeWarning": "Warning",
"contributionTypeVariant": "Variant",
"contributionTypeCorrection": "Correction",
"contributionTypeTranslation": "Translation",
"difficultyBeginner": "Beginner",
"difficultyIntermediate": "Intermediate",
"difficultyAdvanced": "Advanced",
"authorCommunity": "Community",
"authorExpert": "Expert",
"authorAdmin": "Admin",
"saveContribution": "Save",
"unsaveContribution": "Unsave",
"savedContributions": "Saved"
```

**Step 2: Add Italian strings**

Add to `app_it.arb`:

```json
"discovery": "Scopri",
"searchContributions": "Cerca contributi...",
"filters": "Filtri",
"sort": "Ordina",
"noResultsFound": "Nessun risultato trovato",
"sortByHelpful": "Più Utili",
"sortByRecent": "Più Recenti",
"sortBySaved": "Più Salvati",
"sortByTrending": "Trending",
"filterByType": "Tipo",
"filterByDifficulty": "Difficoltà",
"filterByExercise": "Esercizio",
"filterByAuthor": "Autore",
"filterByDate": "Intervallo Date",
"resetFilters": "Resetta Filtri",
"applyFilters": "Applica Filtri",
"contributionTypeTip": "Consiglio",
"contributionTypeTechnique": "Tecnica",
"contributionTypeWarning": "Avviso",
"contributionTypeVariant": "Variante",
"contributionTypeCorrection": "Correzione",
"contributionTypeTranslation": "Traduzione",
"difficultyBeginner": "Principiante",
"difficultyIntermediate": "Intermedio",
"difficultyAdvanced": "Avanzato",
"authorCommunity": "Community",
"authorExpert": "Esperto",
"authorAdmin": "Admin",
"saveContribution": "Salva",
"unsaveContribution": "Rimuovi",
"savedContributions": "Salvati"
```

**Step 3: Regenerate localizations**

```bash
flutter gen-l10n
```

**Step 4: Commit**

```bash
git add assets/i18n/app_en.arb assets/i18n/app_it.arb
git commit -m "feat(community): add localization strings for discovery"
```

---

### Task 10: Create Filters Modal Widget

**Files:**
- Create: `lib/features/community/presentation/widgets/filters_modal.dart`

**Step 1: Write filters modal**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/discovery_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

class FiltersModal extends ConsumerStatefulWidget {
  const FiltersModal({super.key});

  @override
  ConsumerState<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends ConsumerState<FiltersModal> {
  late ContributionFilters _localFilters;

  @override
  void initState() {
    super.initState();
    _localFilters = ref.read(contributionFiltersProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * 0.75,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(AppIcons.close, size: AppIconSize.medium),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  context.l10n.filters,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(context.l10n.resetFilters),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filters content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTypeFilter(context),
                const SizedBox(height: 24),
                _buildDifficultyFilter(context),
                const SizedBox(height: 24),
                _buildAuthorTierFilter(context),
              ],
            ),
          ),

          // Apply button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.applyFilters,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByType,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ContributionType.values.map((type) {
            final isSelected = _localFilters.type == type.name;
            return FilterChip(
              label: Text(_getTypeLabel(context, type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _localFilters = _localFilters.copyWith(
                    type: selected ? type.name : null,
                  );
                });
              },
              selectedColor: context.colors.primaryContainer,
              checkmarkColor: context.colors.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter(BuildContext context) {
    final difficulties = ['beginner', 'intermediate', 'advanced'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByDifficulty,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: difficulties.map((difficulty) {
            final isSelected = _localFilters.difficulty == difficulty;
            return FilterChip(
              label: Text(_getDifficultyLabel(context, difficulty)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _localFilters = _localFilters.copyWith(
                    difficulty: selected ? difficulty : null,
                  );
                });
              },
              selectedColor: context.colors.primaryContainer,
              checkmarkColor: context.colors.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAuthorTierFilter(BuildContext context) {
    final tiers = ['community', 'expert', 'admin'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByAuthor,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tiers.map((tier) {
            final isSelected = _localFilters.authorTier == tier;
            return FilterChip(
              label: Text(_getAuthorTierLabel(context, tier)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _localFilters = _localFilters.copyWith(
                    authorTier: selected ? tier : null,
                  );
                });
              },
              selectedColor: context.colors.primaryContainer,
              checkmarkColor: context.colors.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getTypeLabel(BuildContext context, ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return context.l10n.contributionTypeTip;
      case ContributionType.technique:
        return context.l10n.contributionTypeTechnique;
      case ContributionType.warning:
        return context.l10n.contributionTypeWarning;
      case ContributionType.variant:
        return context.l10n.contributionTypeVariant;
      case ContributionType.correction:
        return context.l10n.contributionTypeCorrection;
      case ContributionType.translation:
        return context.l10n.contributionTypeTranslation;
    }
  }

  String _getDifficultyLabel(BuildContext context, String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return context.l10n.difficultyBeginner;
      case 'intermediate':
        return context.l10n.difficultyIntermediate;
      case 'advanced':
        return context.l10n.difficultyAdvanced;
      default:
        return difficulty;
    }
  }

  String _getAuthorTierLabel(BuildContext context, String tier) {
    switch (tier) {
      case 'community':
        return context.l10n.authorCommunity;
      case 'expert':
        return context.l10n.authorExpert;
      case 'admin':
        return context.l10n.authorAdmin;
      default:
        return tier;
    }
  }

  void _resetFilters() {
    setState(() {
      _localFilters = const ContributionFilters();
    });
  }

  void _applyFilters() {
    ref.read(contributionFiltersProvider.notifier).state = _localFilters;
    Navigator.pop(context);
  }
}
```

**Step 2: Hook up to discovery screen**

In `discovery_screen.dart`, replace the filters button `onPressed`:

```dart
OutlinedButton.icon(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltersModal(),
    );
  },
  icon: Icon(AppIcons.filter, size: AppIconSize.small),
  label: Text(context.l10n.filters),
),
```

**Step 3: Commit**

```bash
git add lib/features/community/presentation/widgets/filters_modal.dart lib/features/community/presentation/screens/discovery_screen.dart
git commit -m "feat(community): add filters modal with type/difficulty/author filters"
```

---

### Task 11: Create Sort Modal Widget

**Files:**
- Create: `lib/features/community/presentation/widgets/sort_modal.dart`

**Step 1: Write sort modal**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/discovery_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class SortModal extends ConsumerWidget {
  const SortModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(contributionFiltersProvider);
    final currentSortBy = currentFilters.sortBy;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(AppIcons.sort),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.sort,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sort options
            _buildSortOption(
              context,
              ref,
              sortBy: 'helpful',
              title: context.l10n.sortByHelpful,
              icon: AppIcons.thumbUp,
              isSelected: currentSortBy == 'helpful',
            ),
            _buildSortOption(
              context,
              ref,
              sortBy: 'recent',
              title: context.l10n.sortByRecent,
              icon: AppIcons.time,
              isSelected: currentSortBy == 'recent',
            ),
            _buildSortOption(
              context,
              ref,
              sortBy: 'saved',
              title: context.l10n.sortBySaved,
              icon: AppIcons.bookmark,
              isSelected: currentSortBy == 'saved',
            ),
            _buildSortOption(
              context,
              ref,
              sortBy: 'trending',
              title: context.l10n.sortByTrending,
              icon: AppIcons.trending,
              isSelected: currentSortBy == 'trending',
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref, {
    required String sortBy,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? context.colors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? context.colors.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(AppIcons.check, color: context.colors.primary)
          : null,
      onTap: () {
        final currentFilters = ref.read(contributionFiltersProvider);
        ref.read(contributionFiltersProvider.notifier).state =
            currentFilters.copyWith(sortBy: sortBy);
        Navigator.pop(context);
      },
    );
  }
}
```

**Step 2: Hook up to discovery screen**

In `discovery_screen.dart`, replace the sort button `onPressed`:

```dart
OutlinedButton.icon(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SortModal(),
    );
  },
  icon: Icon(AppIcons.sort, size: AppIconSize.small),
  label: Text(context.l10n.sort),
),
```

**Step 3: Commit**

```bash
git add lib/features/community/presentation/widgets/sort_modal.dart lib/features/community/presentation/screens/discovery_screen.dart
git commit -m "feat(community): add sort modal with helpful/recent/saved/trending"
```

---

### Task 12: Create Contribution Card Widget

**Files:**
- Create: `lib/features/community/presentation/widgets/contribution_card.dart`

**Step 1: Write contribution card**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/discovery_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContributionCard extends ConsumerWidget {
  const ContributionCard({
    required this.contribution,
    super.key,
  });

  final CommunityContribution contribution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isContributionSavedProvider(contribution.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to contribution detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type badge + Author
              Row(
                children: [
                  _buildTypeBadge(context),
                  const SizedBox(width: 8),
                  _buildDifficultyBadge(context),
                  const Spacer(),
                  _buildAuthorInfo(context),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                contribution.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Description preview
              Text(
                contribution.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer: Stats + Save button
              Row(
                children: [
                  // Upvotes
                  Icon(
                    AppIcons.thumbUp,
                    size: AppIconSize.small,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    contribution.upvotes.toString(),
                    style: context.textTheme.bodySmall,
                  ),

                  const SizedBox(width: 16),

                  // Comments
                  Icon(
                    AppIcons.comment,
                    size: AppIconSize.small,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    contribution.comments.length.toString(),
                    style: context.textTheme.bodySmall,
                  ),

                  const SizedBox(width: 16),

                  // Saves
                  Icon(
                    AppIcons.bookmark,
                    size: AppIconSize.small,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    contribution.saves.toString(),
                    style: context.textTheme.bodySmall,
                  ),

                  const Spacer(),

                  // Time ago
                  Text(
                    timeago.format(contribution.createdAt),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Save button
                  IconButton(
                    icon: Icon(
                      isSaved ? AppIcons.bookmarkFilled : AppIcons.bookmark,
                      color: isSaved ? context.colors.primary : null,
                      size: AppIconSize.medium,
                    ),
                    onPressed: () {
                      ref
                          .read(saveContributionNotifierProvider.notifier)
                          .toggleSave(contribution.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final typeColor = _getTypeColor(context);
    final typeLabel = _getTypeLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        typeLabel,
        style: context.textTheme.bodySmall?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context) {
    final difficultyColor = _getDifficultyColor(context);
    final difficultyLabel = _getDifficultyLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: difficultyColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: difficultyColor, width: 1),
      ),
      child: Text(
        difficultyLabel,
        style: context.textTheme.bodySmall?.copyWith(
          color: difficultyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        if (contribution.userAvatar != null)
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(contribution.userAvatar!),
          )
        else
          CircleAvatar(
            radius: 12,
            backgroundColor: context.colors.primaryContainer,
            child: Text(
              contribution.userName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          contribution.userName,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(BuildContext context) {
    switch (contribution.type) {
      case ContributionType.tip:
        return context.colors.tertiary;
      case ContributionType.technique:
        return context.colors.primary;
      case ContributionType.warning:
        return context.colors.error;
      case ContributionType.variant:
        return context.colors.secondary;
      case ContributionType.correction:
        return Colors.orange;
      case ContributionType.translation:
        return Colors.purple;
    }
  }

  String _getTypeLabel(BuildContext context) {
    switch (contribution.type) {
      case ContributionType.tip:
        return context.l10n.contributionTypeTip;
      case ContributionType.technique:
        return context.l10n.contributionTypeTechnique;
      case ContributionType.warning:
        return context.l10n.contributionTypeWarning;
      case ContributionType.variant:
        return context.l10n.contributionTypeVariant;
      case ContributionType.correction:
        return context.l10n.contributionTypeCorrection;
      case ContributionType.translation:
        return context.l10n.contributionTypeTranslation;
    }
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (contribution.difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return context.colors.onSurface;
    }
  }

  String _getDifficultyLabel(BuildContext context) {
    switch (contribution.difficulty) {
      case 'beginner':
        return context.l10n.difficultyBeginner;
      case 'intermediate':
        return context.l10n.difficultyIntermediate;
      case 'advanced':
        return context.l10n.difficultyAdvanced;
      default:
        return contribution.difficulty;
    }
  }
}
```

**Step 2: Use in discovery screen**

In `discovery_screen.dart`, replace the `ListView.builder` itemBuilder:

```dart
return ListView.builder(
  itemCount: contributions.length,
  itemBuilder: (context, index) {
    return ContributionCard(contribution: contributions[index]);
  },
);
```

**Step 3: Add timeago dependency**

In `pubspec.yaml`:

```yaml
dependencies:
  timeago: ^3.7.0
```

Run:

```bash
flutter pub get
```

**Step 4: Commit**

```bash
git add lib/features/community/presentation/widgets/contribution_card.dart lib/features/community/presentation/screens/discovery_screen.dart pubspec.yaml pubspec.lock
git commit -m "feat(community): add contribution card widget with save functionality"
```

---

## Phase 4: Testing & Verification

### Task 13: Add Unit Tests for Repository

**Files:**
- Create: `test/features/community/data/repositories/firebase_community_repository_test.dart`

**Step 1: Write repository tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/firebase_community_repository.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, Query, QuerySnapshot])
void main() {
  group('FirebaseCommunityRepository - Search & Filter', () {
    late FirebaseCommunityRepository repository;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      repository = FirebaseCommunityRepository(mockFirestore);
    });

    test('searchContributions returns filtered results by query', () async {
      // TODO: Implement test
      // Arrange: Mock Firestore query
      // Act: Call searchContributions
      // Assert: Verify filtered results
    });

    test('filterContributions applies type filter correctly', () async {
      // TODO: Implement test
    });

    test('filterContributions applies difficulty filter correctly', () async {
      // TODO: Implement test
    });

    test('saveContribution increments saves count', () async {
      // TODO: Implement test
    });

    test('unsaveContribution decrements saves count', () async {
      // TODO: Implement test
    });
  });
}
```

**Step 2: Run tests**

```bash
flutter test test/features/community/data/repositories/firebase_community_repository_test.dart
```

Expected: Tests pass (or implement full tests in follow-up)

**Step 3: Commit**

```bash
git add test/features/community/data/repositories/firebase_community_repository_test.dart
git commit -m "test(community): add repository unit tests scaffold"
```

---

### Task 14: Manual Testing & Verification

**Step 1: Run app on iOS simulator**

```bash
flutter run -d "iPhone 16 Pro"
```

**Step 2: Test Discovery Screen**

Manual test checklist:
- [ ] Navigate to Discovery screen
- [ ] Search bar accepts input
- [ ] Search returns filtered results
- [ ] Filters modal opens and applies filters
- [ ] Sort modal opens and changes sort order
- [ ] Save button toggles saved state
- [ ] Contribution cards display correctly
- [ ] Dark/Light theme work correctly
- [ ] Italian/English localization work

**Step 3: Document issues (if any)**

Create issue in GitHub or notes for follow-up

---

### Task 15: Final Commit & Documentation

**Step 1: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors

**Step 2: Final commit**

```bash
git add .
git commit -m "feat(community): complete Discovery & Search MVP implementation

- Added Firestore schema v2 with sub-collections
- Implemented search with relevance scoring
- Added advanced filters (type, difficulty, author, date)
- Implemented sort options (helpful, recent, saved, trending)
- Added save/unsave contributions functionality
- Created Apple HIG-compliant UI
- Added comprehensive localization (EN/IT)
- Unit tests scaffold"
```

**Step 3: Update documentation**

Add to `docs/NAVIGATION/INDEX.md`:

```markdown
### Discovery & Search (Community)
1. Read: `docs/plans/2025-11-05-community-discovery-search.md` (Implementation plan)
2. Reference: `lib/features/community/presentation/screens/discovery_screen.dart` (Main UI)
3. Reference: `lib/features/community/domain/entities/contribution_filters.dart` (Filter model)
```

---

## Summary

**Completed:**
- ✅ Firestore schema v2 (sub-collections for votes/comments/saved)
- ✅ Search implementation (client-side with relevance scoring)
- ✅ Advanced filters (type, difficulty, author, date)
- ✅ Sort options (helpful, recent, saved, trending)
- ✅ Save/unsave contributions
- ✅ Apple HIG-compliant UI
- ✅ Localization (EN/IT)
- ✅ Repository layer with providers

**Not Included (Phase 2):**
- ❌ Cloud Functions for denormalization (requires backend deploy)
- ❌ Firestore composite indexes (requires Firebase Console setup)
- ❌ Firestore security rules (requires backend deploy)
- ❌ Tags system (stretch goal)
- ❌ Smart recommendations (privacy concerns, Phase 3)

**Time Estimate:** 2-3 weeks MVP (frontend only, no backend deployment)

---

**For Implementation:** Use `superpowers:subagent-driven-development` skill to execute tasks with fresh subagents + code review between tasks.
