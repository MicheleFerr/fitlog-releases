import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/home_widget_config.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';

class RecentWorkoutsWidget extends ConsumerWidget {
  final WidgetSize size;
  
  const RecentWorkoutsWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (size) {
      case WidgetSize.small:
        return _buildCompactView(context, ref);
      case WidgetSize.medium:
        return _buildStandardView(context, ref);
      case WidgetSize.large:
        return _buildExpandedView(context, ref);
    }
  }

  Widget _buildCompactView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    final userEmail = authService.currentUser?.email;
    
    if (userEmail == null) {
      return _buildEmptyState(context, 'Accedi per vedere i workout');
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.tertiary.withValues(alpha: 0.08),
              theme.colorScheme.tertiary.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('exerciseActivities')
              .where('email', isEqualTo: userEmail.toLowerCase())
              .orderBy('createdAt', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyContent(context, 'Nessun workout recente');
            }
            
            final workout = snapshot.data!.docs.first;
            final data = workout.data() as Map<String, dynamic>;
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp?.toDate() ?? DateTime.now();
            
            return InkWell(
              onTap: () => context.push('/history'),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.history,
                            color: theme.colorScheme.tertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ultimo Workout',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      data['exerciseName'] ?? 'Workout',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (data['sets'] != null) ...[
                          Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(data['sets'] as List).length} serie',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStandardView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    final userEmail = authService.currentUser?.email;
    
    if (userEmail == null) {
      return _buildEmptyState(context, 'Accedi per vedere i workout');
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.tertiary.withValues(alpha: 0.06),
              theme.colorScheme.tertiary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.tertiary,
                          theme.colorScheme.tertiary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workout Recenti',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ultimi 3 allenamenti',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/history'),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('exerciseActivities')
                    .where('email', isEqualTo: userEmail.toLowerCase())
                    .orderBy('createdAt', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyContent(context, 'Nessun workout da mostrare');
                  }
                  
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final workout = snapshot.data!.docs[index];
                      final data = workout.data() as Map<String, dynamic>;
                      return _buildWorkoutItem(context, data, compact: true);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    final userEmail = authService.currentUser?.email;
    
    if (userEmail == null) {
      return _buildEmptyState(context, 'Accedi per vedere i workout');
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.tertiary.withValues(alpha: 0.04),
              theme.colorScheme.tertiary.withValues(alpha: 0.01),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.tertiary,
                          theme.colorScheme.tertiary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cronologia Completa',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tutti i tuoi allenamenti recenti',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push('/history'),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(AppLocalizations.of(context)!.viewAll),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exerciseActivities')
                  .where('email', isEqualTo: userEmail.toLowerCase())
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(48),
                    child: _buildEmptyContent(context, 'Inizia il tuo primo workout!'),
                  );
                }
                
                // Group workouts by date
                final Map<String, List<Map<String, dynamic>>> groupedWorkouts = {};
                for (final doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['createdAt'] as Timestamp?;
                  final date = timestamp?.toDate() ?? DateTime.now();
                  final dateKey = _formatDate(date);
                  
                  if (!groupedWorkouts.containsKey(dateKey)) {
                    groupedWorkouts[dateKey] = [];
                  }
                  groupedWorkouts[dateKey]!.add(data);
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: groupedWorkouts.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.key,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...entry.value.map((workout) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildWorkoutItem(context, workout, compact: false),
                          )),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem(BuildContext context, Map<String, dynamic> data, {required bool compact}) {
    final theme = Theme.of(context);
    final timestamp = data['createdAt'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();
    final sets = data['sets'] as List? ?? [];
    
    // Calculate total volume
    double totalVolume = 0;
    for (final set in sets) {
      final weight = (set['weight'] ?? 0).toDouble();
      final reps = (set['reps'] ?? 0).toInt();
      totalVolume += weight * reps;
    }
    
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(compact ? 8 : 12),
            ),
            child: Center(
              child: Icon(
                Icons.fitness_center,
                color: theme.colorScheme.primary,
                size: compact ? 20 : 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['exerciseName'] ?? 'Workout',
                  style: (compact ? theme.textTheme.bodyLarge : theme.textTheme.titleMedium)?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildWorkoutStat(
                        icon: Icons.repeat,
                        value: '${sets.length}',
                        label: 'serie',
                        theme: theme,
                      ),
                      const SizedBox(width: 16),
                      _buildWorkoutStat(
                        icon: Icons.fitness_center,
                        value: '${totalVolume.toStringAsFixed(0)} kg',
                        label: 'volume',
                        theme: theme,
                      ),
                      const SizedBox(width: 16),
                      _buildWorkoutStat(
                        icon: Icons.access_time,
                        value: _formatTime(date),
                        label: '',
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (compact)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyContent(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}