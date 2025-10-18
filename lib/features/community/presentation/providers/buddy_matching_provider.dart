import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/buddy_preferences.dart';

// Provider per il profilo buddy dell'utente corrente
final currentUserBuddyProfileProvider = FutureProvider<BuddyProfile?>((ref) async {
  try {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser?.uid == null) return null;
    
    final doc = await FirebaseFirestore.instance
        .collection('buddy_profiles')
        .doc(currentUser!.uid)
        .get();
        
    if (!doc.exists) return null;
    
    return BuddyProfile.fromFirestore(doc);
  } catch (e) {
    // print('Error loading buddy profile: $e');
    // Return null instead of throwing to show setup view
    return null;
  }
});

// Provider per match attivi
final activeMatchesProvider = StreamProvider<List<BuddyMatch>>((ref) {
  try {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser?.uid == null) return Stream.value([]);
    
    return FirebaseFirestore.instance
        .collection('buddy_matches')
        .where('participants', arrayContains: currentUser!.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
          BuddyMatch.fromFirestore(doc)).toList())
        .handleError((error) {
          // print('Error loading active matches: $error');
          return [];
        });
  } catch (e) {
    // print('Error in activeMatchesProvider: $e');
    return Stream.value([]);
  }
});

// Provider per match pendenti
final pendingMatchesProvider = StreamProvider<List<BuddyMatch>>((ref) {
  try {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser?.uid == null) return Stream.value([]);
    
    return FirebaseFirestore.instance
        .collection('buddy_matches')
        .where('participants', arrayContains: currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
          BuddyMatch.fromFirestore(doc)).toList())
        .handleError((error) {
          // print('Error loading pending matches: $error');
          return [];
        });
  } catch (e) {
    // print('Error in pendingMatchesProvider: $e');
    return Stream.value([]);
  }
});

// Provider per potenziali match
final potentialMatchesProvider = FutureProvider<List<BuddyProfile>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.uid == null) return [];
  
  // Get current user's preferences
  final userProfile = await ref.read(currentUserBuddyProfileProvider.future);
  if (userProfile == null) return [];
  
  // Query for compatible buddies
  final query = await FirebaseFirestore.instance
      .collection('buddy_profiles')
      .where('isLookingForBuddy', isEqualTo: true)
      .where('userId', isNotEqualTo: currentUser!.uid)
      .limit(20)
      .get();
      
  final potentialMatches = query.docs
      .map((doc) => BuddyProfile.fromFirestore(doc))
      .where((profile) => _calculateCompatibility(userProfile, profile) > 0.5)
      .toList();
      
  // Sort by compatibility score
  potentialMatches.sort((a, b) => 
    _calculateCompatibility(userProfile, b)
        .compareTo(_calculateCompatibility(userProfile, a)));
        
  return potentialMatches;
});

// Calculate compatibility between two profiles
double _calculateCompatibility(BuddyProfile user, BuddyProfile other) {
  double score = 0;
  double maxScore = 0;
  
  // Schedule compatibility (weight: 30%)
  final scheduleOverlap = user.preferences.workoutSchedule
      .toSet()
      .intersection(other.preferences.workoutSchedule.toSet())
      .length;
  score += (scheduleOverlap / user.preferences.workoutSchedule.length) * 30;
  maxScore += 30;
  
  // Fitness level compatibility (weight: 20%)
  final levelDiff = (user.preferences.fitnessLevel.index - 
                     other.preferences.fitnessLevel.index).abs();
  score += (1 - levelDiff / 2) * 20; // Max diff is 2
  maxScore += 20;
  
  // Goals compatibility (weight: 25%)
  final goalsOverlap = user.preferences.goals
      .toSet()
      .intersection(other.preferences.goals.toSet())
      .length;
  if (user.preferences.goals.isNotEmpty) {
    score += (goalsOverlap / user.preferences.goals.length) * 25;
  }
  maxScore += 25;
  
  // Personality compatibility (weight: 15%)
  if (user.preferences.personalityType == other.preferences.personalityType ||
      user.preferences.personalityType == PersonalityType.mixed ||
      other.preferences.personalityType == PersonalityType.mixed) {
    score += 15;
  }
  maxScore += 15;
  
  // Distance compatibility (weight: 10%)
  // Simplified - in real app would calculate actual distance
  score += 10; // Assume within range for now
  maxScore += 10;
  
  return maxScore > 0 ? score / maxScore : 0;
}

// State notifier for buddy matching actions
class BuddyMatchingNotifier extends StateNotifier<AsyncValue<void>> {
  BuddyMatchingNotifier() : super(const AsyncValue.data(null));
  
  Future<void> savePreferences(
    BuddyPreferences preferences, {
    String? instagramHandle,
    String? location,
    String? bio,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      await FirebaseFirestore.instance
          .collection('buddy_profiles')
          .doc(userId)
          .set({
        'userId': userId,
        'preferences': preferences.toJson(),
        'instagramHandle': instagramHandle,
        'location': location,
        'bio': bio,
        'isLookingForBuddy': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> swipeProfile(String profileId, bool isLike) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      // Record the swipe
      await FirebaseFirestore.instance
          .collection('buddy_swipes')
          .add({
        'fromUserId': userId,
        'toUserId': profileId,
        'isLike': isLike,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      if (isLike) {
        // Check if they liked us back
        final mutualLike = await FirebaseFirestore.instance
            .collection('buddy_swipes')
            .where('fromUserId', isEqualTo: profileId)
            .where('toUserId', isEqualTo: userId)
            .where('isLike', isEqualTo: true)
            .get();
            
        if (mutualLike.docs.isNotEmpty) {
          // Create a match!
          await _createMatch(userId, profileId);
        }
      }
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> _createMatch(String userId1, String userId2) async {
    await FirebaseFirestore.instance.collection('buddy_matches').add({
      'participants': [userId1, userId2],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActivity': FieldValue.serverTimestamp(),
    });
    
    // TODO: Send notification to both users
  }
}

// Provider for the notifier
final buddyMatchingProvider = StateNotifierProvider<BuddyMatchingNotifier, AsyncValue<void>>((ref) {
  return BuddyMatchingNotifier();
});

// Additional entity classes
class BuddyProfile {
  
  BuddyProfile({
    required this.userId,
    required this.preferences,
    this.instagramHandle,
    this.location,
    this.bio,
    this.isLookingForBuddy = true,
    this.createdAt,
  });
  
  factory BuddyProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BuddyProfile(
      userId: data['userId'],
      preferences: BuddyPreferences.fromJson(data['preferences']),
      instagramHandle: data['instagramHandle'],
      location: data['location'],
      bio: data['bio'],
      isLookingForBuddy: data['isLookingForBuddy'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
  final String userId;
  final BuddyPreferences preferences;
  final String? instagramHandle;
  final String? location;
  final String? bio;
  final bool isLookingForBuddy;
  final DateTime? createdAt;
}

class BuddyMatch {
  
  BuddyMatch({
    required this.id,
    required this.participants,
    required this.status,
    required this.createdAt,
    required this.lastActivity,
  });
  
  factory BuddyMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BuddyMatch(
      id: doc.id,
      participants: List<String>.from(data['participants']),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActivity: (data['lastActivity'] as Timestamp).toDate(),
    );
  }
  final String id;
  final List<String> participants;
  final String status;
  final DateTime createdAt;
  final DateTime lastActivity;
}