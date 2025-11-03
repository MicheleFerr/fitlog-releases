/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Widget per le azioni rapide dell'admin dashboard
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/community_corrections_screen.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/database_manager_screen.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/missing_exercises_requests_screen.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_feedback_screen.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/firebase_init_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_feedback_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/widgets/firebase_init_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AdminQuickActions extends ConsumerWidget {
  const AdminQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.quickActions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Griglia delle azioni
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                // Gestione database esercizi
                _QuickActionCard(
                  icon: AppIcons.storage,
                  title: l10n.databaseManager,
                  subtitle: l10n.manageExercisesDescription,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => _navigateToDatabaseManager(context),
                ),

                // Exercise Feedback (NUOVO)
                _QuickActionCardWithBadge(
                  icon: AppIcons.flagCircle,
                  title: 'Exercise Feedback',
                  subtitle: 'Segnalazioni e bug utenti',
                  color: context.colors.tertiary,
                  onTap: () => _navigateToExerciseFeedback(context),
                  badgeProvider: unreadFeedbackCountProvider,
                ),

                // Review contributi community
                _QuickActionCard(
                  icon: Icons.rate_review,
                  title: l10n.communityContributions,
                  subtitle: l10n.reviewContributionsDescription,
                  color: context.colors.secondary,
                  onTap: () => _navigateToCommunityCorrections(context),
                ),

                // Richieste esercizi mancanti
                _QuickActionCard(
                  icon: Icons.fitness_center,
                  title: 'Esercizi Mancanti',
                  subtitle: 'Gestisci richieste esercizi',
                  color: context.colors.warning,
                  onTap: () => _navigateToMissingExercises(context),
                ),

                // Fix dati mancanti
                _QuickActionCard(
                  icon: AppIcons.buildCircle,
                  title: l10n.fixMissingData,
                  subtitle: l10n.fixMissingDataDescription,
                  color: context.colors.primary,
                  onTap: () => _fixMissingData(context, ref),
                ),

                // Statistiche utenti
                _QuickActionCard(
                  icon: Icons.analytics,
                  title: l10n.userAnalytics,
                  subtitle: l10n.userAnalyticsDescription,
                  color: context.colors.success,
                  onTap: () => _showComingSoon(context, l10n),
                ),

                // Backup database
                _QuickActionCard(
                  icon: Icons.backup,
                  title: l10n.databaseBackup,
                  subtitle: l10n.databaseBackupDescription,
                  color: context.colors.tertiary,
                  onTap: () => _showComingSoon(context, l10n),
                ),

                // Notifiche push
                _QuickActionCard(
                  icon: Icons.notifications,
                  title: l10n.pushNotifications,
                  subtitle: l10n.pushNotificationsDescription,
                  color: context.colors.error,
                  onTap: () => _showComingSoon(context, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFirebaseManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    FirebaseInitWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDatabaseManager(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DatabaseManagerScreen(),
      ),
    );
  }

  void _navigateToCommunityCorrections(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CommunityCorrectionsScreen(),
      ),
    );
  }

  void _navigateToMissingExercises(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MissingExercisesRequestsScreen(),
      ),
    );
  }

  void _navigateToExerciseFeedback(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExerciseFeedbackScreen(),
      ),
    );
  }

  void _fixMissingData(BuildContext context, WidgetRef ref) {
    // Mostra dialogo di conferma
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              AppIcons.buildCircle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).fixMissingData),
          ],
        ),
        content: Text(AppLocalizations.of(context).fixMissingDataDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Esegui fix dati mancanti
              ref.read(firebaseInitStateProvider.notifier).fixMissingData();
            },
            child: Text(AppLocalizations.of(context).fix),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.comingSoon),
          ],
        ),
        content: Text(l10n.featureComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick Action Card con badge per contatore real-time
class _QuickActionCardWithBadge extends ConsumerWidget {
  const _QuickActionCardWithBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.badgeProvider,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Provider<int> badgeProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeCount = ref.watch(badgeProvider);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),
                  // Badge count
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: TextStyle(
                            color: context.colors.surface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}