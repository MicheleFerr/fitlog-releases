/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Demo profiles loader
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/providers/buddy_matching_provider.dart';

class DemoProfilesFab extends ConsumerStatefulWidget {
  const DemoProfilesFab({super.key});

  @override
  ConsumerState<DemoProfilesFab> createState() => _DemoProfilesFabState();
}

class _DemoProfilesFabState extends ConsumerState<DemoProfilesFab> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return const SizedBox.shrink(); // COMMENTED OUT - FAB disabled
    // return FloatingActionButton.extended(
    //   onPressed: _isLoading ? null : _showDemoOptions,
    //   backgroundColor: theme.colorScheme.secondary,
    //   foregroundColor: theme.colorScheme.onSecondary,
    //   icon: _isLoading 
    //       ? SizedBox(
    //           width: 16,
    //           height: 16,
    //           child: CircularProgressIndicator(
    //             strokeWidth: 2,
    //             valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onSecondary),
    //           ),
    //         )
    //       : const Icon(Icons.science),
    //   label: Text(_isLoading ? 'Loading...' : 'Demo'),
    // );
  }

  void _showDemoOptions() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.science,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Demo Profiles',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Carica profili demo per testare il buddy matching',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              // Load Demo Profiles Button
              _buildDemoButton(
                context: context,
                title: 'Carica Profili Demo',
                subtitle: 'Carica 10 profili demo nella tua area',
                icon: Icons.people,
                onPressed: _loadDemoProfiles,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 12),
              
              // Load Near Me Button
              _buildDemoButton(
                context: context,
                title: 'Profili Nella Tua Città',
                subtitle: 'Carica profili demo vicino a te',
                icon: Icons.location_on,
                onPressed: _loadDemoProfilesNearMe,
                color: theme.colorScheme.tertiary,
              ),
              
              const SizedBox(height: 12),
              
              // Reload Button
              _buildDemoButton(
                context: context,
                title: 'Ricarica Demo',
                subtitle: 'Pulisce e ricarica tutti i profili demo',
                icon: Icons.refresh,
                onPressed: _reloadDemoProfiles,
                color: theme.colorScheme.secondary,
              ),
              
              const SizedBox(height: 12),
              
              // Clear Demo Button
              _buildDemoButton(
                context: context,
                title: 'Pulisci Demo',
                subtitle: 'Rimuove tutti i profili demo',
                icon: Icons.delete_outline,
                onPressed: _clearDemoProfiles,
                color: theme.colorScheme.error,
              ),
              
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadDemoProfiles() async {
    await _performDemoAction(() async {
      final loader = ref.read(demoProfilesLoaderProvider);
      await loader.loadDemoProfiles();

      // Refresh matches after loading
      unawaited(ref.read(matchingProvider.notifier).refreshMatches());

      _showSuccessMessage('✅ Profili demo caricati con successo!');
    });
  }

  Future<void> _loadDemoProfilesNearMe() async {
    await _performDemoAction(() async {
      final loader = ref.read(demoProfilesLoaderProvider);
      await loader.loadDemoProfilesNearCurrentUser();

      // Refresh matches after loading
      unawaited(ref.read(matchingProvider.notifier).refreshMatches());

      _showSuccessMessage('✅ Profili demo caricati nella tua area!');
    });
  }

  Future<void> _reloadDemoProfiles() async {
    await _performDemoAction(() async {
      final loader = ref.read(demoProfilesLoaderProvider);
      await loader.reloadDemoProfiles();

      // Refresh matches after loading
      unawaited(ref.read(matchingProvider.notifier).refreshMatches());

      _showSuccessMessage('✅ Profili demo ricaricati!');
    });
  }

  Future<void> _clearDemoProfiles() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Conferma Rimozione',
      message: 'Sei sicuro di voler rimuovere tutti i profili demo?',
    );

    if (!confirmed) return;

    await _performDemoAction(() async {
      final loader = ref.read(demoProfilesLoaderProvider);
      await loader.clearDemoProfiles();

      // Refresh matches after clearing
      unawaited(ref.read(matchingProvider.notifier).refreshMatches());

      _showSuccessMessage('✅ Profili demo rimossi!');
    });
  }

  Future<void> _performDemoAction(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
    });

    Navigator.of(context).pop(); // Close bottom sheet

    try {
      await action();
    } catch (e) {
      _showErrorMessage('❌ Errore: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}