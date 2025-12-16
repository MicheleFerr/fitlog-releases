# Buddy Matching System - Complete Documentation

> **Feature Status**: 85% Implemented | Testing Phase | Production-Ready Security
> **Last Updated**: November 6, 2024
> **Test Coverage**: Domain entities: 93 tests passing | Security rules: Comprehensive validation

## Executive Summary

The Buddy Matching System is a comprehensive social feature that enables users to find workout partners based on compatibility scoring, location matching, and shared fitness goals. The system includes profile management, intelligent matching algorithms, partnership tracking, and tiered premium features.

### Key Features

- **Smart Matching Algorithm**: Multi-factor compatibility scoring (0-100)
- **Tiered Features**: Super Likes, Profile Boosts, Verification badges
- **Location-Based**: City/zone matching with Italian cities support
- **Security-First**: Comprehensive Firebase Security Rules with validation
- **Partnership Management**: Track workouts together, ratings, feedback
- **Safety Features**: Report system, block/ban functionality, trust scores

---

## Architecture

### Domain Layer (Clean Architecture)

#### Entities

**BuddyProfile** (`lib/features/buddy_matching/domain/entities/buddy_profile.dart`)
- Core user profile for matching system
- ~430 lines with comprehensive business logic
- Fields:
  - `uid`, `displayName`, `photoURL`
  - `preferences`: BuddyPreferences object
  - `badges`: List<BadgeType> (9 badge types)
  - `partnershipsCount`, `successfulPartnerships`
  - `averageRating`, `totalRatings`
  - `superLikesRemaining`, `boostExpiry`, `isBoosted`
  - `reportCount`, `isBanned`, `isPhotoVerified`
  - `blockedUsers`, `reportedUsers`
  - `completedWorkoutsTogether`
- Methods:
  - `canMatch()`: Check if two profiles can be matched
  - `getCompatibilityScore()`: Calculate compatibility (0-100)
  - `distanceTo()`: Haversine formula for distance calculation
  - `trustScore`: Multi-factor trust calculation (0-100)
  - `workoutPartnershipStrength`: Completion rate calculation

**BuddyPreferences** (`lib/features/buddy_matching/domain/entities/buddy_preferences.dart`)
- User's matching preferences and filters
- ~314 lines with compatibility algorithm
- Fields:
  - `fitnessLevel`: Beginner/Intermediate/Advanced/Expert
  - `goals`: List<WorkoutGoal> (6 types)
  - `preferredTimes`: List<PreferredTime> (4 time slots)
  - `preferredDays`: List<String>
  - `maxDistance`: km radius for location matching
  - `cityCode`, `zoneName`: Italian cities system integration
  - `matchingPurpose`: WorkoutPartner/GymBuddy/Both/OpenToEverything
  - `matchSameFitnessLevel`, `matchSameGoals`: Filters
- Compatibility Algorithm:
  - **Fitness Level** (30% weight): Perfect/adjacent/distant matching
  - **Goals** (25% weight): Common goals ratio
  - **Time Preferences** (20% weight): Overlapping times
  - **Day Preferences** (15% weight): Common workout days
  - **Bio/Instagram** (10% weight): Profile completeness bonus
  - **Result**: 0-100 score with `wouldMatch()` helper

**BuddyMatch** (`lib/features/buddy_matching/domain/entities/buddy_match.dart`)
- Represents a match between two users
- ~305 lines with partnership logic
- Lifecycle: `pending` → `confirmed` → `partnership` → `completed`
- Fields:
  - `user1Id`, `user2Id`, `compatibilityScore`
  - `status`: MatchStatus enum
  - `expiresAt`: 7-day expiry for pending matches
  - `partnershipStartedAt`, `partnershipEndedAt`
  - `sharedWorkouts`, `plannedWorkouts`, `completedWorkouts`
  - `user1Rating`, `user2Rating`, `user1Feedback`, `user2Feedback`
- Methods:
  - `isMutualMatch`: Both users liked
  - `isExpired`: Check if pending match expired
  - `canStartPartnership()`: Check eligibility
  - `workoutCompletionRate`: Calculate success rate
  - `wasSuccessfulPartnership`: Rating + completion check
  - `getStatusDisplay()`: User-friendly status strings

**BuddyAction** (`lib/features/buddy_matching/domain/entities/buddy_action.dart`)
- User actions: like, superLike, pass, block, report
- Immutable action tracking
- Report reasons: inappropriatePhotos, harassment, spam, fakeProfile, underage, other

#### Repository Interface

**BuddyMatchingRepository** (`lib/features/buddy_matching/domain/repositories/buddy_matching_repository.dart`)
- 159 lines defining complete contract
- **Profile Management**: CRUD operations, preferences, location updates
- **Discovery**: `getPotentialMatches()`, `searchProfiles()`, `getProfilesInRadius()`
- **Matching Actions**: `likeProfile()`, `superLikeProfile()`, `dislikeProfile()`, `confirmMatch()`
- **Partnership**: `startPartnership()`, `endPartnership()`, ratings/feedback
- **Tier-1 Features**: Super likes, boosts, verification
- **Security**: Block/unblock, report users, ban system, trust scores
- **Location**: Italian cities system integration
- **Ice Breakers**: Conversation starters for matches
- **Workout Together**: Track joint workouts, completion rates

### Data Layer

**FirebaseBuddyMatchingRepository** (`lib/features/buddy_matching/data/repositories/firebase_buddy_matching_repository.dart`)
- Implementation of repository interface
- Collections:
  - `buddy_profiles`: User profiles
  - `buddy_matches`: Match records
  - `buddy_actions`: Action history
  - `user_search_filters`: Saved preferences
  - `ice_breakers`: Conversation starters
- **Key Methods**:
  - `getPotentialMatches()`: Stream with real-time updates
  - `likeProfile()`: Creates or updates match, checks for mutual
  - `searchProfiles()`: Advanced filtering with query/location
  - Location queries with geohashing (future: GeoFlutterFire)

### Presentation Layer

**Screens** (10 screens in `lib/features/buddy_matching/presentation/screens/`)
- `buddy_matching_screen.dart`: Main swipe interface
- `buddy_onboarding_screen.dart`: First-time user setup
- `edit_buddy_profile_screen.dart`: Profile management
- `development_screen.dart`: Testing/demo mode

**Widgets** (~20 widgets for enhanced UX)
- `swipeable_buddy_card.dart`: Tinder-like swipe cards
- `matches_preview_bar.dart`: Top bar showing mutual matches
- `instagram_link_button.dart`: Instagram verification
- `city_picker_widget.dart`: Italian cities autocomplete
- `ice_breaker_widget.dart`: Conversation starter suggestions
- `super_like_button.dart`: Premium super like action
- `verification_badges.dart`: Display verification status
- `report_user_dialog.dart`: User safety reporting

---

## Firebase Security Rules

### Location: `firestore.rules` (lines 1242-1365)

Comprehensive security validation with 124 lines of protection:

#### Buddy Profiles Collection (`/buddy_profiles/{profileId}`)

**Read Access**:
- Users can read their own profile
- Users can read active profiles that are looking for buddy
- List queries limited to 50 profiles max

**Write Access**:
- Users can only create/update/delete their own profile
- `uid` field cannot be changed
- `reportCount`, `isBanned`, `isVerified` protected from user tampering
- Validation: `validateBuddyProfileData()` + document size check

#### Buddy Matches Collection (`/buddy_matches/{matchId}`)

**Read Access**:
- Only match participants can read the match
- List operations require authentication + query limits

**Write Access**:
- Only participants can create/update/delete matches
- Match creation validates both user IDs
- Updates must follow status transition rules:
  - `pending` → `confirmed`, `expired`, `cancelled`
  - `confirmed` → `partnership`, `cancelled`
  - `partnership` → `completed`, `cancelled`
- `compatibilityScore` immutable after creation

#### Buddy Actions Collection (`/buddy_actions/{actionId}`)

**Read Access**:
- Users can only read their own actions

**Write Access**:
- Users can only create actions from themselves
- Actions are immutable (no updates)
- Report actions cannot be deleted

**Report Validation**:
- Requires `reportReason` + `reportDescription` (10-500 chars)
- Valid reasons: inappropriatePhotos, harassment, spam, fakeProfile, underage, other

#### Buddy Messages (Subcollection: `/buddy_matches/{matchId}/messages/{messageId}`)

**Read/Write Access**:
- Only match participants
- Message content: 1-1000 characters
- Messages are immutable (cannot update/delete)

#### Helper Collections

- **user_search_filters**: Private per user
- **ice_breakers**: Read-only for users, admin write-only

### Validation Functions (9 helpers)

1. **validateBuddyProfileData**: Checks structure, required fields, string lengths
2. **validateBuddyProfileUpdate**: Prevents critical field tampering
3. **validateBuddyPreferences**: Validates preference structure, ranges
4. **validateBuddyMatchData**: Match structure, score range (0-100)
5. **validateBuddyMatchUpdate**: User IDs immutable, status transitions
6. **validateBuddyMatchStatusTransition**: State machine validation
7. **validateBuddyActionData**: Action structure, self-action prevention
8. **validateBuddyReport**: Report requirements (reason + description)

---

## Testing

### Domain Tests: 93 tests passing

**BuddyPreferences Tests** (28 tests)
- Fitness level compatibility (4 scenarios)
- Goals compatibility (4 scenarios)
- Time/day preferences (5 scenarios)
- Bio/Instagram bonus
- Overall score validation (0-100 range)
- `wouldMatch()` helper with thresholds
- Location helpers (hasLocation, hasRecentLocation)
- Enum display names

**BuddyMatch Tests** (37 tests)
- Match creation factory
- User identification helpers
- Mutual match detection
- Expiration logic
- Partnership management (start, end, duration)
- Workout stats (completion rate)
- Rating/feedback system
- Successful partnership criteria
- Status display strings

**BuddyProfile Tests** (28 tests - existing)
- Super Likes system
- Boost system (cooldown, expiry)
- Verification badges
- Security (block/ban/report)
- Workout together tracking
- Trust score calculation
- Matchability checks
- Enhanced compatibility with bonuses

### Firebase Security Rules Tests

**TODO**: Create integration tests for rules enforcement
- Test unauthorized access attempts
- Test validation function edge cases
- Test status transition violations
- Test report system requirements

### Integration Tests

**TODO**: Create repository integration tests
- CRUD operations with real Firestore emulator
- Sync conflict resolution
- Real-time stream updates
- Location-based queries

---

## API Reference

### BuddyProfile Extensions

```dart
profile.canMatch(otherProfile) → bool
profile.getCompatibilityScore(otherProfile) → double  // 0-100
profile.distanceTo(otherProfile) → double?  // km (Haversine)
profile.trustScore → double  // 0-100
profile.isOnline → bool  // Last seen < 5min
profile.isRecentlyActive → bool  // Last seen < 30min
profile.hasActivePartnership → bool
profile.successRate → double  // %
profile.hasBadge(BadgeType) → bool
profile.workoutPartnershipStrength → double  // 0-100
profile.canSuperLike → bool  // superLikesRemaining > 0
profile.isCurrentlyBoosted → bool
profile.needsSuperLikeReset → bool  // Daily reset
profile.isBlocked → bool  // isBanned || reportCount >= 5
profile.isMatchable → bool  // !isBlocked && isActive
profile.hasBlocked(userId) → bool
profile.hasReported(userId) → bool
profile.canStartBoost() → bool  // Cooldown check
```

### BuddyPreferences Extensions

```dart
preferences.getCompatibilityScore(other) → double  // 0-100
preferences.wouldMatch(other, {minScore: 60.0}) → bool
preferences.hasLocation → bool
preferences.hasRecentLocation → bool  // < 24h
```

### BuddyMatch Extensions

```dart
match.getOtherUserId(currentUserId) → String
match.hasUserLiked(userId) → bool
match.isMutualMatch → bool
match.isExpired → bool
match.getUnreadCount(userId) → int
match.canStartPartnership(userId) → bool
match.isActivePartnership → bool
match.partnershipDurationDays → int?
match.workoutCompletionRate → double  // 0-1
match.averageRating → double?
match.wasSuccessfulPartnership → bool  // Rating >= 4 && completion >= 70%
match.timeUntilExpiration → Duration?
match.getStatusDisplay({currentUserId}) → String
```

---

## Configuration

### Firestore Indexes

**TODO**: Add required composite indexes

```firestore
# Potential matches query
Collection: buddy_profiles
Fields:
  - preferences.isLookingForBuddy (Ascending)
  - isActive (Ascending)
  - compatibilityScore (Descending)

# Location-based queries (with GeoFlutterFire)
Collection: buddy_profiles
Fields:
  - geohash (Ascending)
  - preferences.isLookingForBuddy (Ascending)

# User matches query
Collection: buddy_matches
Fields:
  - user1Id (Ascending)
  - status (Ascending)
  - updatedAt (Descending)

# Alternative query
Collection: buddy_matches
Fields:
  - user2Id (Ascending)
  - status (Ascending)
  - updatedAt (Descending)
```

### Environment Variables

```dart
// Demo mode (for testing without real Firestore)
const bool kDemoMode = false;  // Set in demo_profiles_loader.dart

// Super Like limits
const int kDailySuperLikes = 3;  // Default in BuddyProfile

// Match expiry
const int kMatchExpiryDays = 7;  // Default in BuddyMatch.create()

// Distance limits
const double kMinDistance = 1.0;  // km
const double kMaxDistance = 100.0;  // km

// Report threshold for auto-ban
const int kReportBanThreshold = 5;  // In BuddyProfile.isBlocked
```

---

## User Flow Examples

### 1. New User Onboarding

```
1. User completes quick start in app
2. Navigate to Buddy Matching screen
3. Show onboarding if first time:
   - Explain matching concept
   - Set up profile (name, bio, photo)
   - Configure preferences (fitness level, goals, times, location)
   - Grant location permission (optional)
4. Start discovering profiles
```

### 2. Liking a Profile

```
1. User sees potential match card
2. Swipe right OR tap "Like" button
3. System checks:
   - Is this a super like? (if yes: decrement superLikesRemaining)
   - Does a match already exist? (check buddy_matches)
4. IF existing match:
   - Set user2LikedAt timestamp
   - Update status: pending → confirmed
   - Notify both users of mutual match
5. IF new match:
   - Create BuddyMatch with status: pending
   - Add targetUserId to currentUser.likedProfiles
6. Show next profile
```

### 3. Mutual Match Flow

```
1. User receives notification: "It's a match!"
2. Navigate to Matches tab
3. See new mutual match with icebreaker suggestions
4. Option 1: Send message (opens chat)
5. Option 2: Start Partnership
   - Confirm partnership intent
   - Set partnershipStartedAt
   - Update both profiles: currentPartnershipId
   - Status: confirmed → partnership
6. Track workouts together
```

### 4. Partnership Lifecycle

```
PENDING → user1 likes user2 (7-day expiry timer starts)
   ↓
CONFIRMED → user2 likes user1 (mutual match)
   ↓
PARTNERSHIP → One user initiates partnership
   ↓ (After workouts together)
   ↓
COMPLETED → Either user ends partnership
   ↓
   → Rate partner (1-5 stars)
   → Leave feedback (optional)
   → Calculate success metrics
   → Award badges if criteria met
```

### 5. Report/Block Flow

```
1. User taps "..." on profile card
2. Select "Report" or "Block"
3. IF Report:
   - Choose reason (inappropriatePhotos, harassment, spam, fakeProfile, underage, other)
   - Write description (10-500 chars)
   - Submit to buddy_actions collection
   - Increment reportedUser.reportCount
   - IF reportCount >= 5: Auto-ban user
4. IF Block:
   - Add targetUserId to blockedUsers list
   - Remove from potential matches immediately
   - Hide all past interactions
```

---

## Premium Tier Features

### Super Likes (Tier-1)

- **Limit**: 3 per day (resets midnight local time)
- **Visual**: Gold star icon, prominent notification to recipient
- **Check**: `profile.canSuperLike` before allowing action
- **Reset**: Daily via `resetDailySuperLikes()` repository method
- **Effect**: Priority in recipient's match queue

### Profile Boost (Tier-1)

- **Duration**: 30 minutes (customizable)
- **Cooldown**: 24 hours between boosts
- **Check**: `profile.canStartBoost()` before allowing action
- **Effect**: 10x visibility in discovery queue
- **Visual**: Lightning bolt icon on profile

### Verification Badges (Tier-1)

- **Types**:
  - `verified`: Manual admin verification
  - `instagramVerified`: Connected Instagram account
  - `photoVerified`: Selfie match verification
- **Trust Bonus**: +20/+15/+10 to trustScore
- **Compatibility Bonus**: +5 if both users verified

---

## Performance Considerations

### Optimization Strategies

1. **Pagination**: Load 20 profiles at a time
2. **Caching**: Cache viewed profiles for 24h
3. **Location Indexing**: Use GeoFlutterFire for efficient radius queries
4. **Real-time Streams**: Only for active matches (not all discovery)
5. **Image Loading**: Lazy load profile photos, cache with CachedNetworkImage

### Known Limitations

1. **Distance Calculation**: Haversine is approximate (not road distance)
2. **Location Updates**: Manual refresh (no background location tracking)
3. **Query Limits**: Max 50 profiles per query (Firestore limit)
4. **No Video Profiles**: Only static images supported
5. **Chat System**: Basic (future: rich media, reactions)

---

## Future Roadmap

### Phase 1: Core Improvements (Q1 2025)

- [ ] Video profile support (15-30s intro videos)
- [ ] Enhanced chat (media, reactions, voice notes)
- [ ] Group workout matching (3-5 people)
- [ ] Workout scheduling integration
- [ ] Push notifications for new matches

### Phase 2: Advanced Features (Q2 2025)

- [ ] Machine learning compatibility scoring
- [ ] Behavioral analysis (response time, partnership success)
- [ ] Gamification (streaks, challenges with buddy)
- [ ] Premium subscription tiers (unlimited super likes, incognito mode)
- [ ] Social proof (mutual friends, gyms)

### Phase 3: Scale (Q3 2025)

- [ ] Multi-language support (EN, IT, ES, DE, FR)
- [ ] Global expansion beyond Italy
- [ ] Advanced moderation (AI content filtering)
- [ ] Analytics dashboard for users
- [ ] Partner gym integrations

---

## Related Documentation

- **Entity Details**: See individual entity files for comprehensive inline documentation
- **Repository Implementation**: `firebase_buddy_matching_repository.dart` for Firestore integration
- **Security Rules**: `firestore.rules` lines 1242-1365 for validation logic
- **Domain Tests**: `test/features/buddy_matching/domain/entities/` for test examples
- **Italian Cities System**: See `shared/domain/entities/italian_city.dart` for location integration

---

## Maintenance Notes

### Known Issues

1. **Legacy Test Files**: `firebase_buddy_matching_repository_test.dart` has outdated entity structure (needs refactor)
2. **Missing Indexes**: Firestore composite indexes not yet configured
3. **Location Permission**: iOS requires background location capability for live updates

### Monitoring

**Key Metrics to Track**:
- Match success rate (confirmed / pending)
- Partnership completion rate (completed / started)
- Average compatibility score of successful partnerships
- Report/block rate (moderation needs)
- Super like usage (premium feature engagement)

**Firebase Analytics Events**:
- `buddy_profile_created`
- `buddy_like_sent` (isSuperLike: bool)
- `buddy_match_confirmed`
- `buddy_partnership_started`
- `buddy_partnership_completed` (rating: int, wasSuccessful: bool)
- `buddy_report_submitted` (reason: String)

---

**Version**: 1.0.0
**Author**: Michele (Development Team)
**License**: Proprietary - GymBro TrackLog
