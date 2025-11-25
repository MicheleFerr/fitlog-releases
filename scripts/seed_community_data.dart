/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Script: Seed Community Data
/// 🎯 Purpose: Populate Firestore with mock community contributions for testing
///
/// Usage:
/// ```bash
/// # Run from project root
/// dart scripts/seed_community_data.dart
/// ```
///
/// What it does:
/// - Generates 20+ realistic community contributions
/// - Uploads to Firestore `community_contributions` collection
/// - Creates realistic user contribution stats
/// - Adds comments, upvotes, saves for testing
///
/// ⚠️ WARNING: This script uses PRODUCTION Firebase!
/// - Only run in development/testing environments
/// - Review data before running
/// - Can be run multiple times (idempotent - uses same IDs)
library;

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro_flutter_new/features/community/data/mock_community_data.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';

Future<void> main() async {
  print('🏋️ GymBro TrackLog - Community Data Seeder');
  print('=' * 60);
  print('');

  // Ask for confirmation
  print('⚠️  WARNING: This will populate Firestore with mock data.');
  print('   Collection: community_contributions');
  print('   Documents: ~20+ contributions');
  print('');
  stdout.write('Continue? (y/n): ');
  final confirmation = stdin.readLineSync();

  if (confirmation?.toLowerCase() != 'y') {
    print('❌ Aborted by user.');
    exit(0);
  }

  print('');
  print('🔥 Initializing Firebase...');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('✅ Firebase initialized');
  print('');

  // Generate mock data
  print('📊 Generating mock contributions...');
  final mockContributions = MockCommunityData.generateMockContributions();
  print('   Generated: ${mockContributions.length} contributions');
  print('');

  // Upload to Firestore
  print('📤 Uploading to Firestore...');
  int uploadedCount = 0;
  int skippedCount = 0;
  int errorCount = 0;

  for (final contribution in mockContributions) {
    try {
      final docRef = firestore
          .collection('community_contributions')
          .doc(contribution.id);

      // Check if document exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('   ⏭️  Skipped: ${contribution.id} (already exists)');
        skippedCount++;
        continue;
      }

      // Convert to JSON and prepare for Firestore
      final data = contribution.toJson();

      // Convert DateTime to Timestamp
      data['createdAt'] = Timestamp.fromDate(contribution.createdAt);
      if (contribution.updatedAt != null) {
        data['updatedAt'] = Timestamp.fromDate(contribution.updatedAt!);
      }
      if (contribution.reviewedAt != null) {
        data['reviewedAt'] = Timestamp.fromDate(contribution.reviewedAt!);
      }
      if (contribution.lastActivityAt != null) {
        data['lastActivityAt'] = Timestamp.fromDate(contribution.lastActivityAt!);
      }

      // Convert enums to strings
      data['type'] = contribution.type.name;
      data['status'] = contribution.status.name;

      // Convert comments to JSON
      data['comments'] = contribution.comments.map((comment) {
        final commentData = comment.toJson();
        commentData['createdAt'] = Timestamp.fromDate(comment.createdAt);
        return commentData;
      }).toList();

      // Upload to Firestore
      await docRef.set(data);

      print('   ✅ Uploaded: ${contribution.id} - ${contribution.title.substring(0, 40)}...');
      uploadedCount++;

      // Rate limiting (avoid Firestore quota issues)
      await Future.delayed(const Duration(milliseconds: 100));

    } catch (e) {
      print('   ❌ Error uploading ${contribution.id}: $e');
      errorCount++;
    }
  }

  print('');
  print('=' * 60);
  print('📊 Summary:');
  print('   ✅ Uploaded: $uploadedCount contributions');
  print('   ⏭️  Skipped: $skippedCount contributions (already exist)');
  if (errorCount > 0) {
    print('   ❌ Errors: $errorCount contributions');
  }
  print('');

  // Create sample user stats
  print('👤 Creating sample user contribution stats...');

  final userStatsData = [
    {
      'userId': 'mock_user_001',
      'totalPoints': 450,
      'level': 'Expert',
      'totalContributions': 5,
      'approvedContributions': 5,
      'rejectedContributions': 0,
      'pendingContributions': 0,
    },
    {
      'userId': 'mock_user_002',
      'totalPoints': 320,
      'level': 'Contributor',
      'totalContributions': 3,
      'approvedContributions': 3,
      'rejectedContributions': 0,
      'pendingContributions': 0,
    },
    {
      'userId': 'mock_user_008',
      'totalPoints': 50,
      'level': 'Rookie',
      'totalContributions': 1,
      'approvedContributions': 0,
      'rejectedContributions': 1,
      'pendingContributions': 0,
    },
  ];

  for (final statsData in userStatsData) {
    try {
      await firestore
          .collection('user_contribution_stats')
          .doc(statsData['userId'] as String)
          .set({
            ...statsData,
            'lastActivity': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('   ✅ Stats created for: ${statsData['userId']}');
    } catch (e) {
      print('   ❌ Error creating stats for ${statsData['userId']}: $e');
    }
  }

  print('');
  print('🎉 Seeding complete!');
  print('');
  print('📱 Next Steps:');
  print('   1. Set your user isAdmin = true in Firestore');
  print('   2. Restart your app');
  print('   3. Navigate to Community Discovery');
  print('   4. You should see all mock contributions!');
  print('');
  print('🔧 To set isAdmin = true:');
  print('   Firebase Console → Firestore → users → [your_uid]');
  print('   Add field: isAdmin = true');
  print('');
}
