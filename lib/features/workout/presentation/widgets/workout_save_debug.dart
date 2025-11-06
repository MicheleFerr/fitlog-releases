import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget di debug per mostrare gli allenamenti salvati in Firestore
class WorkoutSaveDebug extends ConsumerWidget {
  const WorkoutSaveDebug({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firebaseUser = ref.watch(firebaseUserProvider);
    
    if (authState != AuthState.authenticated) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('🔐 Login necessario per vedere le attività salvate'),
        ),
      );
    }

    return firebaseUser.when(
      data: (user) {
        if (user?.email == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('❌ Email utente non disponibile'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🗄️ Debug Firestore',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('👤 Utente: ${user!.email}'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showSavedActivities(context, ref, user.email!),
                  icon: const Icon(AppIcons.history),
                  label: const Text('Vedi Attività Salvate'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Caricamento utente...'),
            ],
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('❌ Errore: $error'),
        ),
      ),
    );
  }

  void _showSavedActivities(BuildContext context, WidgetRef ref, String userEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Text(
                '📋 Attività Salvate',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: FutureBuilder<List<ExerciseActivity>>(
                  future: ref.read(exerciseActivityRepositoryProvider)
                      .getUserActivities(userEmail: userEmail, limit: 20),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(AppIcons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Errore: ${snapshot.error}'),
                          ],
                        ),
                      );
                    }
                    
                    final activities = snapshot.data ?? [];
                    
                    if (activities.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(AppIcons.workout, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nessuna attività salvata ancora'),
                            SizedBox(height: 8),
                            Text(
                              'Completa un allenamento per vedere qui i dati!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: activity.exerciseImage != null
                                  ? NetworkImage(activity.exerciseImage!)
                                  : null,
                              child: activity.exerciseImage == null
                                  ? const Icon(AppIcons.workout)
                                  : null,
                            ),
                            title: Text(activity.exerciseName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📋 ${activity.schedaName}'),
                                Text('🔢 ${activity.sets.length} sets'),
                                Text('📅 ${_formatDate(activity.createdAt)}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(AppIcons.info),
                              onPressed: () => _showActivityDetails(context, activity),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context, ExerciseActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.exerciseName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📋 Scheda: ${activity.schedaName}'),
              Text('📧 Utente: ${activity.email}'),
              Text('🆔 ID: ${activity.exerciseId}'),
              Text('📅 Data: ${_formatDate(activity.createdAt)}'),
              const SizedBox(height: 16),
              const Text('💪 Sets:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...activity.sets.map((set) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Set ${set.set}: ${set.weight}kg × ${set.reps} reps '
                  '${set.done ? "✅" : "❌"} (Effort: ${set.effort}/5)',
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
