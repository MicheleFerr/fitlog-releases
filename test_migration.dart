import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_migration_service.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';

Future<void> main() async {
  print('Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final migrationService = AnalyticsMigrationService(firestore: firestore);

  print('Starting migration test...');

  // Replace with actual user ID
  const userId = '3CvzsGHxQrQPhcfb1HgdmJHLCh03';

  final result = await migrationService.migrateUserWorkouts(userId: userId);

  result.fold(
    (failure) => print('Migration failed: $failure'),
    (stats) {
      print('Migration succeeded!');
      print(stats);
    },
  );

  print('Test complete.');
}