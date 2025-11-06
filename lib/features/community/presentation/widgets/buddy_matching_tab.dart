/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: community
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: Via providers
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/buddy_matching_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/buddy_onboarding_screen.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/buddy_matching_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class BuddyMatchingTab extends ConsumerWidget {
  const BuddyMatchingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final currentProfile = ref.watch(currentUserBuddyProfileProvider);
    final activeMatches = ref.watch(activeMatchesProvider);
    final pendingMatches = ref.watch(pendingMatchesProvider);

    return currentProfile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // Se l'errore è perché il profilo non esiste, mostra setup
        // print('Buddy profile error: $error');
        return _buildSetupView(context, theme, l10n);
      },
      data: (profile) {
        if (profile == null || !profile.preferences.isLookingForBuddy) {
          return _buildSetupView(context, theme, l10n);
        }

        return _buildActiveView(context, theme, l10n, activeMatches, pendingMatches);
      },
    );
  }

  Widget _buildSetupView(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(
              AppIcons.handshake,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'Trova il tuo Workout Buddy',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Connettiti con persone che condividono i tuoi obiettivi fitness',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Setup button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToOnboarding(context),
              icon: const Icon(AppIcons.personAdd),
              label: const Text('Inizia'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Alternative: Go directly to matching
          OutlinedButton.icon(
            onPressed: () => _navigateToMatching(context),
            icon: const Icon(AppIcons.explore),
            label: const Text('Esplora ora'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AsyncValue<List<dynamic>> activeMatches,
    AsyncValue<List<dynamic>> pendingMatches,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with edit button
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.person, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Il tuo profilo Buddy', 
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _navigateToEditProfile(context),
                    icon: const Icon(AppIcons.edit),
                    tooltip: 'Modifica profilo',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  theme,
                  AppIcons.explore,
                  'Trova Partner',
                  'Scopri nuovi buddy',
                  () => _navigateToMatching(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  theme,
                  AppIcons.settings,
                  'Preferenze',
                  'Modifica filtri',
                  () => _navigateToOnboarding(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Pending matches
          pendingMatches.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (matches) {
              if (matches.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        AppIcons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nuovi Match (${matches.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...matches.take(3).map((match) => _buildMatchCard(context, theme, match)),
                  if (matches.length > 3)
                    TextButton(
                      onPressed: () => _navigateToAllMatches(context),
                      child: Text('Vedi tutti (${matches.length})'),
                    ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),

          // Active partnerships
          activeMatches.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (matches) {
              final partnerships = matches.where((m) => m.status == 'partnership').toList();
              if (partnerships.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        AppIcons.handshake,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Partnership Attive',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...partnerships.map((match) => _buildPartnershipCard(context, theme, match)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, ThemeData theme, dynamic match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            AppIcons.person,
            color: theme.colorScheme.primary,
          ),
        ),
        title: const Text('Nuovo Match!'),
        subtitle: const Text('In attesa di conferma'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(AppIcons.close, color: Colors.red),
              onPressed: () => _handleMatchAction(context, match, false),
            ),
            IconButton(
              icon: const Icon(AppIcons.favorite, color: Colors.green),
              onPressed: () => _handleMatchAction(context, match, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnershipCard(BuildContext context, ThemeData theme, dynamic match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          child: const Icon(
            AppIcons.handshake,
            color: Colors.green,
          ),
        ),
        title: const Text('Partnership Attiva'),
        subtitle: const Text('Partnership attiva'),
        trailing: IconButton(
          icon: const Icon(AppIcons.chat),
          onPressed: () => _openChat(context, match),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.error,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Errore nel caricamento',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _navigateToOnboarding(context),
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BuddyOnboardingScreen(),
      ),
    );
  }

  void _navigateToMatching(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BuddyMatchingScreen(),
      ),
    );
  }

  void _navigateToAllMatches(BuildContext context) {
    // Navigate to full matches screen
  }

  void _handleMatchAction(BuildContext context, dynamic match, bool accept) {
    // Handle match accept/reject
  }

  void _openChat(BuildContext context, dynamic match) {
    // Open chat screen
  }

  void _navigateToEditProfile(BuildContext context) {
    // For now, navigate back to onboarding
    // TODO: Create dedicated edit profile screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BuddyOnboardingScreen(),
      ),
    );
  }
}
